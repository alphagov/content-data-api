class GA::Processor
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time(process: :ga) do
      extract_events
      transform_events
      load_metrics
    end
  end

private

  def extract_events
    batch = 1
    ga_service.find_in_batches(date: date) do |events|
      log process: :ga, message: "Processing #{events.length} events in batch #{batch}"
      Events::GA.import(events, batch_size: 10_000)
      batch += 1
    end
  end

  def transform_events
    fix_invalid_prefix_in_page_paths
  end

  def load_metrics
    conn = ActiveRecord::Base.connection
    date_to_s = date.strftime("%F")

    conn.execute(load_metrics_query(date_to_s))
    conn.execute(clean_up_query)
  end

  def load_metrics_query(date_to_s)
    <<~SQL
      UPDATE facts_metrics
      SET unique_pageviews = s.unique_pageviews,
          pageviews = s.pageviews
      FROM (
        SELECT pageviews,
               unique_pageviews,
               dimensions_items.id
        FROM events_gas, dimensions_items
        WHERE page_path = base_path
              AND events_gas.date = '#{date_to_s}'
      ) AS s
      WHERE dimensions_item_id = s.id AND dimensions_date_id = '#{date_to_s}'
    SQL
  end

  def clean_up_query
    date_to_s = date.strftime("%F")
    <<~SQL
      DELETE FROM events_gas
      WHERE date = '#{date_to_s}' AND
        page_path in (
           SELECT base_path
           FROM dimensions_items, facts_metrics
           WHERE dimensions_items.id = facts_metrics.dimensions_item_id
           AND facts_metrics.dimensions_date_id = '#{date_to_s}'
        )
    SQL
  end

  def fix_invalid_prefix_in_page_paths
    events_with_prefix = Events::GA.where("page_path ~ '^\/https:\/\/www.gov.uk'")
    log(process: :ga, message: "Transforming #{events_with_prefix.count} events with page_path starting https://gov.uk")
    events_with_prefix.find_each do |event|
      page_path_without_prefix = event.page_path.remove '/https://www.gov.uk'
      event.update_attributes(page_path: page_path_without_prefix)
    end
  end

  attr_reader :date

  def ga_service
    @ga_service ||= GA::Service.new
  end
end

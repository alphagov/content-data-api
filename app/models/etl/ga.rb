class ETL::GA
  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    extract_events
    load_metrics
  end

private

  def extract_events
    ga_service.find_in_batches(date: date) do |events|
      Events::GA.import(events, batch_size: 10_000)
    end
  end

  def load_metrics
    conn = ActiveRecord::Base.connection
    date_to_s = date.strftime("%F")

    conn.execute(load_metrics_query(date_to_s))
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
        WHERE page_path = base_path AND latest = 'true'
      ) AS s
      WHERE dimensions_item_id = s.id AND dimensions_date_id = '#{date_to_s}'
    SQL
  end

  attr_reader :date

  def ga_service
    @ga_service ||= GoogleAnalyticsService.new
  end
end

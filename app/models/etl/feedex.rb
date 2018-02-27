class ETL::Feedex
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
    feedex_service.find_in_batches(date: date) do |events|
      Events::Feedex.import(events, batch_size: 10_000)
    end
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
      SET number_of_issues = s.number_of_issues
      FROM (
        SELECT base_path,
               number_of_issues,
               dimensions_items.id
        FROM events_feedexes, dimensions_items
        WHERE page_path = base_path AND latest = 'true'
      ) AS s
      WHERE dimensions_item_id = s.id AND dimensions_date_id = '#{date_to_s}'
    SQL
  end

  def clean_up_query
    date_to_s = date.strftime("%F")
    <<~SQL
      DELETE FROM events_feedexes
      WHERE date = '#{date_to_s}' AND
        page_path in (
           SELECT base_path
           FROM dimensions_items
           WHERE latest = 'true'
        )
    SQL
  end

  attr_reader :date

  def feedex_service
    @feedex_service ||= FeedexService.new
  end
end

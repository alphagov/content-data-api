class Etl::Feedex::Processor
  include TraceAndRecoverable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time_and_trap(process: :feedex) do
      extract_events
      load_metrics
    end
  end

private

  BATCH_SIZE = 10_000

  def extract_events
    batch = 1
    Etl::Feedex::Service.find_in_batches(date, BATCH_SIZE) do |events|
      log process: :feedex, message: "Processing #{events.length} events in batch #{batch}"
      Events::Feedex.import(events, batch_size: BATCH_SIZE)
      batch += 1
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
      SET feedex = s.feedex_comments
      FROM (
        SELECT base_path,
               feedex_comments,
               dimensions_editions.id
        FROM events_feedexes, dimensions_editions
        WHERE page_path = base_path
          AND events_feedexes.date = '#{date_to_s}'
      ) AS s
      WHERE dimensions_edition_id = s.id AND dimensions_date_id = '#{date_to_s}'
    SQL
  end

  def clean_up_query
    date_to_s = date.strftime("%F")
    <<~SQL
      DELETE FROM events_feedexes
      WHERE date = '#{date_to_s}' AND
        page_path in (
           SELECT base_path
           FROM dimensions_editions, facts_metrics
           WHERE dimensions_editions.id = facts_metrics.dimensions_edition_id
           AND facts_metrics.dimensions_date_id = '#{date_to_s}'
        )
    SQL
  end

  attr_reader :date
end

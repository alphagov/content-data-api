require_dependency "concerns/trace_and_recoverable"
class Etl::GA::InternalSearchProcessor
  include TraceAndRecoverable
  include Etl::GA::Concerns::TransformPath

  def self.process(*args, **kwargs)
    new(*args, **kwargs).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time_and_trap(process: :ga_search) do
      puts "process internal search metrics"
      # extract_bigquery_data
      extract_events
      transform_events
      load_metrics
    end
  end

private

  def extract_bigquery_data
    Etl::GA::InternalSearchService.get_bigquery_data(date:)
  end

  def extract_events
    batch = 1
    Etl::GA::InternalSearchService.find_in_batches(date:) do |events|
      log process: :ga, message: "Processing #{events.length} events in batch #{batch}"
      Events::GA.import(events, batch_size: 10_000)
      batch += 1
    end
  end

  def transform_events
    format_events_with_invalid_prefix
  end

  def load_metrics
    conn = ActiveRecord::Base.connection
    date_to_s = date.strftime("%F")
    # binding.pry
    results = conn.execute(load_metrics_query(date_to_s))
    puts results
    clean_up_events!
  end
  # insert into facts_metrics (dimensions_edition_id, dimensions_date_id) 
  # values (15625129, "Thu, 02 Nov 2023");
  def load_metrics_query(date_to_s)
    <<~SQL
      UPDATE facts_metrics
      SET searches = s.searches
      FROM (
        SELECT searches,
               dimensions_editions.id
        FROM events_gas, dimensions_editions
        WHERE page_path = LOWER(base_path)
              AND events_gas.date = '#{date_to_s}'
      ) AS s
      WHERE dimensions_edition_id = s.id AND dimensions_date_id = '#{date_to_s}'
    SQL
  end

  def clean_up_events!
    Events::GA.delete_all
  end

  attr_reader :date
end

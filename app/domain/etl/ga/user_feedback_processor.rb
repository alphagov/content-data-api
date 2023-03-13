require_dependency "concerns/trace_and_recoverable"
class Etl::GA::UserFeedbackProcessor
  include TraceAndRecoverable
  include Etl::GA::Concerns::TransformPath

  def self.process(*args, **kwargs)
    new(*args, **kwargs).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time_and_trap(process: :ga_feedback) do
      extract_events
      transform_events
      load_metrics
    end
  end

private

  def extract_events
    batch = 1
    Etl::GA::UserFeedbackService.find_in_batches(date:) do |events|
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
    conn.execute(load_metrics_query(date_to_s))
    clean_up_events!
  end

  def load_metrics_query(date_to_s)
    <<~SQL
      UPDATE facts_metrics
      SET useful_no = s.useful_no,
          useful_yes = s.useful_yes,
          satisfaction= s.useful_yes / NULLIF((s.useful_yes + s.useful_no::float),0)
      FROM (
        SELECT useful_no,
               useful_yes,
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

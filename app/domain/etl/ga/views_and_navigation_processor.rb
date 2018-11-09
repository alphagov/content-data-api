require_dependency 'concerns/traceable'
class Etl::GA::ViewsAndNavigationProcessor
  include Concerns::Traceable
  include Etl::GA::Concerns::TransformPath

  def self.process(*args)
    new(*args).process
  end

  def initialize(date:)
    @date = date
  end

  def process
    time(process: :ga_views_navigation) do
      extract_events
      transform_events
      load_metrics
    end
  end

private

  def extract_events
    batch = 1
    Etl::GA::ViewsAndNavigationService.find_in_batches(date: date) do |events|
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
      SET upviews = s.upviews,
          pviews = s.pviews,
          entrances = s.entrances,
          exits = s.exits,
          bounce_rate = s.bounce_rate,
          avg_page_time = s.avg_page_time,
          bounces = s.bounces,
          page_time = s.page_time
      FROM (
        SELECT pviews,
               upviews,
               entrances,
               exits,
               bounce_rate,
               avg_page_time,
               bounces,
               page_time,
               dimensions_editions.id
        FROM events_gas, dimensions_editions
        WHERE page_path = base_path
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

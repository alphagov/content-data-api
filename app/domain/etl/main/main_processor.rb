class Etl::Main::MainProcessor
  include Traceable

  def self.process(*args, **kwargs)
    new(*args, **kwargs).process
  end

  def self.process_aggregations(*args, **kwargs)
    new(*args, **kwargs).process_aggregations
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    delete_existing_metrics if already_run?

    processor_failures = 0
    monitor_failures = 0

    time(process: :main) do
      processor_failures = [
        Etl::Main::MetricsProcessor.process(date:),
        Etl::GA::ViewsAndNavigationProcessor.process(date:),
        Etl::GA::UserFeedbackProcessor.process(date:),
        Etl::GA::InternalSearchProcessor.process(date:),
        Etl::Feedex::Processor.process(date:),
      ].count(false)

      process_aggregations unless historic_data?
    end

    time(process: :monitor) do
      unless historic_data?
        monitor_failures = [
          Monitor::Etl.run,
          Monitor::Dimensions.run,
          Monitor::Facts.run,
          Monitor::Aggregations.run,
        ].count(false)
      end
    end

    (processor_failures + monitor_failures).zero?
  end

  def process_aggregations
    Etl::Aggregations::Monthly.process(date:)
    Etl::Aggregations::Search.process
  end

  def already_run?
    Facts::Metric.where(dimensions_date_id: date).any?
  end

private

  attr_reader :date

  def historic_data?
    date != Date.yesterday
  end

  def delete_existing_metrics
    Facts::Metric.where(dimensions_date_id: @date).delete_all
  end
end

class Etl::Master::MasterProcessor
  include Traceable

  def self.process(*args)
    new(*args).process
  end

  def self.process_aggregations(*args)
    new(*args).process_aggregations
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    delete_existing_metrics if already_run?

    processor_failures = 0
    monitor_failures = 0

    time(process: :master) do
      processor_failures = [
        Etl::Master::MetricsProcessor.process(date: date),
        Etl::GA::ViewsAndNavigationProcessor.process(date: date),
        Etl::GA::UserFeedbackProcessor.process(date: date),
        Etl::GA::InternalSearchProcessor.process(date: date),
        Etl::Feedex::Processor.process(date: date),
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
    Etl::Aggregations::Monthly.process(date: date)
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

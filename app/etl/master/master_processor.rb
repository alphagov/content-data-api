class Master::MasterProcessor
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    raise DuplicateDateError if Dimensions::Date.exists?(date)
    time(process: :master) do
      Master::MetricsProcessor.process(date: dimensions_date.date)
      GA::ViewsProcessor.process(date: dimensions_date.date)
      GA::UserFeedbackProcessor.process(date: dimensions_date.date)
      GA::InternalSearchProcessor.process(date: dimensions_date.date)
      Feedex::Processor.process(date: dimensions_date.date)
    end
  end

private

  def dimensions_date
    @dimensions_date ||= Dimensions::Date.for(date)
  end

  attr_reader :date

  class DuplicateDateError < StandardError;
  end
end

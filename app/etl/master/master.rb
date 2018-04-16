class Master::Master
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
      Master::OutdatedItems.process(date: dimensions_date.date)
      Master::Metrics.process(date: dimensions_date.date)
      GA::GA.process(date: dimensions_date.date)
      Feedex::Feedex.process(date: dimensions_date.date)
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

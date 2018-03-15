class ETL::Master
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    time(process: :master) do
      ETL::OutdatedItems.process(date: dimensions_date.date)
      ETL::Metrics.process(date: dimensions_date.date)
      ETL::GA.process(date: dimensions_date.date)
      ETL::Feedex.process(date: dimensions_date.date)
    end
  end

private


  def dimensions_date
    @dimensions_date ||= Dimensions::Date.for(date)
  end

  attr_reader :date
end

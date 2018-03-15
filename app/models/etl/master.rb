class ETL::Master
  def self.process(*args)
    new(*args).process
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    ETL::OutdatedItems.process(date: dimensions_date.date)
    ETL::Facts.process(date: dimensions_date.date)
    ETL::GA.process(date: dimensions_date.date)
    ETL::Feedex.process(date: dimensions_date.date)
  end

private


  def dimensions_date
    @dimensions_date ||= Dimensions::Date.for(date)
  end

  attr_reader :date
end

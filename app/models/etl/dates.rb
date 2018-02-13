class ETL::Dates
  def self.process(*args)
    new(*args).process
  end

  def process
    Dimensions::Date.for(Date.today)
  end
end

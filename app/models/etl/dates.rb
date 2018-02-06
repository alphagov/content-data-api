class ETL::Dates
  def self.process(*args)
    new(*args).process
  end

  def process
    Dimensions::Date.for(Date.yesterday)
  end
end

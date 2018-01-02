class ETL::Dates
  def self.process(*args)
    new(*args).process
  end

  def process
    Dimensions::Date.find(Date.today)
  rescue ActiveRecord::RecordNotFound
    date = Dimensions::Date.build(Date.today)
    date.save!
    date
  end
end

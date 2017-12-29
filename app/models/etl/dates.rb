class ETL::Dates
  def process
    Dimensions::Date.find(Date.today)
  rescue ActiveRecord::RecordNotFound
    date = Dimensions::Date.build(Date.today)
    date.save!
  end
end

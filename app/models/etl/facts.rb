class ETL::Facts
  def self.process(*args)
    new(*args).process
  end

  def process(date:)
    dimensions_date ||= Dimensions::Date.for(date)
    Dimensions::Item.where(latest: true).find_in_batches(batch_size: 50000) do |batch|
      values = batch.pluck(:id).map do |value|
        {
          dimensions_date_id: dimensions_date.date,
          dimensions_item_id: value,
        }
      end
      Facts::Metric.import(values, validate: false)
    end
  end
end

class ETL::Facts
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def process(date:)
    time(process: :metrics) do
      create_metrics(date)
    end
  end

private

  def create_metrics(date)
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

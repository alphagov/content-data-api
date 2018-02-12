class ETL::Master
  def self.process(*args)
    new(*args).process
  end

  def process
    initialize_facts_table
  end

private

  def initialize_facts_table
    Dimensions::Item.where(latest: true).find_in_batches(batch_size: 50000) do |batch|
      values = batch.pluck(:id, :organisation_id)
      metrics = values.map do |value|
        {
          dimensions_date_id: date.date,
          dimensions_item_id: value[0],
        }
      end
      Facts::Metric.import(metrics, validate: false)
    end
  end

  def date
    @date ||= ETL::Dates.process
  end
end

class ETL::Master
  def self.process(*args)
    new(*args).process
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    create_new_version_for_dirty_items
    initialize_facts_table
    update_with_google_analytics_metrics
    update_with_feedex_metrics
  end

private

  def create_new_version_for_dirty_items
    ETL::OutdatedItems.process(date: dimensions_date.date)
  end

  def initialize_facts_table
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

  def update_with_google_analytics_metrics
    ETL::GA.process(date: dimensions_date.date)
  end

  def update_with_feedex_metrics
    ETL::Feedex.process(date: dimensions_date.date)
  end

  def dimensions_date
    @dimensions_date ||= Dimensions::Date.for(date)
  end

  attr_reader :date
end

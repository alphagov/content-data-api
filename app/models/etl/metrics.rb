class ETL::Metrics
  def self.process(*args)
    new(*args).process
  end

  def process
    ETL::Items.process

    create_metrics
  end

private

  def create_metrics
    Facts::Metric.where(dimensions_date: date).delete_all

    Dimensions::Item.where(latest: true).find_in_batches(batch_size: 50000) do |batch|
      values = batch.pluck(:id, :organisation_id)
      metrics = values.map do |value|
        {
          dimensions_date_id: date.date,
          dimensions_item_id: value[0],
          dimensions_organisation_id: dimension_organisation(value[1], organisations).try(:id)
        }
      end
      Facts::Metric.import(metrics, validate: false)
    end
  end

  def date
    @date ||= ETL::Dates.process
  end

  def organisations
    @organisations ||= ETL::Organisations.process
  end

  def dimension_organisation(organisation_id, organisations)
    organisations.detect { |org| org.content_id == organisation_id }
  end
end

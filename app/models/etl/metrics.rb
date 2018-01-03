class ETL::Metrics
  def self.process(*args)
    new(*args).process
  end

  def process
    items = ETL::Items.process

    create_metric(items)
  end

private

  def create_metric(items)
    Facts::Metric.where(dimensions_date: date).delete_all

    metrics = items.map do |item|
      Facts::Metric.new(
        dimensions_date: date,
        dimensions_item: item,
        dimensions_organisation: dimension_organisation(item, organisations)
      )
    end

    Facts::Metric.import(metrics, validate: false, batch_size: 5000)
  end

  def date
    @date ||= ETL::Dates.process
  end

  def organisations
    @organisations ||= ETL::Organisations.process
  end

  def dimension_organisation(item, organisations)
    organisations.detect { |org| org.content_id == item.organisation_id }
  end
end

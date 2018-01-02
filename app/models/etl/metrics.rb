class ETL::Metrics
  def self.process(*args)
    new(*args).process
  end

  def process
    items = ETL::Items.process

    items.each { |item| create_metric(item) }
  end


private

  def create_metric(item)
    Facts::Metric.find_or_create_by!(
      dimensions_date: date,
      dimensions_item: item,
      dimensions_organisation: dimension_organisation(item, organisations)
    )
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

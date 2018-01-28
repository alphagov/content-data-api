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

    Dimensions::Item.select(:id, :organisation_id, :link).where(latest: true).find_in_batches(batch_size: 500) do |batch|
      pageviews = google_analytics_service
                    .pageviews_for_date(date.date, *batch.pluck(:link))
                    .each_with_object({}) { |i, h| h[i[:base_path]] = i.slice(:page_views, :unique_page_views) }

      metrics = batch.map do |item_dimension|
        {
          dimensions_date_id: date.date,
          dimensions_item_id: item_dimension.id,
          dimensions_organisation_id: dimension_organisation(item_dimension.organisation_id, organisations).try(:id),
          pageviews: pageviews.dig(item_dimension.link, :page_views),
          unique_pageviews: pageviews.dig(item_dimension.link, :unique_page_views),
        }
      end

      Facts::Metric.import(metrics, validate: false)
    end
  end

  def date
    @date ||= ETL::Dates.process
  end

  def google_analytics_service
    @google_analytics_service ||= GoogleAnalyticsService.new
  end

  def organisations
    @organisations ||= ETL::Organisations.process
  end

  def dimension_organisation(organisation_id, organisations)
    organisations.detect { |org| org.content_id == organisation_id }
  end
end

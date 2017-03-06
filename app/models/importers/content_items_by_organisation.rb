module Importers
  class ContentItemsByOrganisation
    attr_accessor :metric_builder, :content_items_service

    def initialize
      @metric_builder = MetricBuilder.new
      @content_items_service = ContentItemsService.new
    end

    def run(slug)
      organisation = Organisation.find_by(slug: slug)
      content_items_service.find_each(slug) do |content_item_attributes|
        metrics = metric_builder.run_all(content_item_attributes)
        ContentItem.create_or_update!(metrics.merge(content_item_attributes), organisation)
      end
    end
  end
end

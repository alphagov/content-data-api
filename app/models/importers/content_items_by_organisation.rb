module Importers
  class ContentItemsByOrganisation
    attr_accessor :metric_builder

    def initialize
      @metric_builder = MetricBuilder.new
    end

    def run(slug)
      organisation = Organisation.find_by(slug: slug)
      ContentItemsService.new.find_each(slug) do |content_item_attributes|
        metric_builder.run_all(content_item_attributes)
        create_or_update!(content_item_attributes, organisation)
      end
    end

  private

    def create_or_update!(attributes, organisation)
      content_id = attributes.fetch(:content_id)
      content_item = ContentItem.find_or_create_by(content_id: content_id)

      content_item.update!(attributes)
      content_item.organisations << organisation unless content_item.organisations.include?(organisation)
    end
  end
end

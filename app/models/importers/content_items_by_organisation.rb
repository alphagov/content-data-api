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
        ContentItem.create_or_update!(content_item_attributes, organisation)
      end
    end
  end
end

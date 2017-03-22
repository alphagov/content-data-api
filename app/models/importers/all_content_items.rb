module Importers
  class AllContentItems
    attr_accessor :metric_builder, :content_items_service, :document_types
    attr_writer :document_types

    def initialize
      @metric_builder = MetricBuilder.new
      @content_items_service = ContentItemsService.new
    end

    def run
      document_types.each do |type|
        content_items_service.find_each(type) do |content_item_attributes|
          metrics = metric_builder.run_all(content_item_attributes)
          ContentItem.create_or_update!(metrics.merge(content_item_attributes))
        end
      end
    end

    def document_types
      @document_types ||= Rails.configuration.document_types
    end
  end
end

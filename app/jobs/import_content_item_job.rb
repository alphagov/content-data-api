class ImportContentItemJob < ApplicationJob
  attr_accessor :content_items_service, :metric_builder

  def initialize(*)
    super

    self.content_items_service = ContentItemsService.new
    self.metric_builder = MetricBuilder.new
  end

  def perform(*args)
    content_id = args[0]

    attributes = content_items_service.fetch(content_id)
    attributes = attributes.merge(content_items_service.links(content_id))
    attributes = attributes.merge(metric_builder.run_all(attributes))

    ContentItem.create_or_update!(attributes)
  end
end

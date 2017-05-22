module Importers
  class SingleContentItem
    attr_accessor :content_items_service, :metric_builder

    def self.run(*args)
      new.run(*args)
    end

    def initialize
      self.content_items_service = ContentItemsService.new
      self.metric_builder = MetricBuilder.new
    end

    def run(content_id)
      attributes = content_items_service.fetch(content_id)
      links = content_items_service.links(content_id)
      attributes = attributes.merge(links)
      attributes = attributes.merge(metric_builder.run_all(attributes))

      # Use a single transaction, so that the content change and links
      # change is atomic with respect to other transactions.
      ActiveRecord::Base.transaction do
        ContentItem.create_or_update!(attributes)
        create_links(content_id, links)
      end
    end

  private

    def create_links(source_content_id, links)
      new_links = links.flat_map do |type, content_ids|
        content_ids.map do |content_id|
          {
            source_content_id: source_content_id,
            link_type: type,
            target_content_id: content_id,
          }
        end
      end

      Link.where(source_content_id: source_content_id).delete_all
      Link.create(new_links)
    end
  end
end

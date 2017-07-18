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
      content_item = content_items_service.fetch(content_id)
      links = content_items_service.links(content_id)

      set_metrics(content_item)

      ActiveRecord::Base.transaction do
        overwrite_content_item!(content_item)
        overwrite_links!(content_id, links)
      end
    end

  private

    def set_metrics(content_item)
      metrics = metric_builder.run_all(content_item)
      metrics.each { |k, v| content_item.public_send(:"#{k}=", v) }
    end

    def overwrite_content_item!(content_item)
      existing = ContentItem.find_by(content_id: content_item.content_id)

      if existing
        attributes = content_item
          .attributes
          .symbolize_keys
          .except(:id, :created_at, :updated_at)

        existing.attributes = attributes

        existing.save!
      else
        content_item.save!
      end
    end

    def overwrite_links!(content_id, links)
      Link.where(source_content_id: content_id).destroy_all

      links.each(&:save!)
    end
  end
end

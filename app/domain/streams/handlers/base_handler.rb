class Streams::Handlers::BaseHandler
  def update_editions(items_with_old_editions)
    publishing_api_event = Events::PublishingApi.new(payload: @payload, routing_key: @routing_key)
    items_to_grow = items_with_old_editions.select do |item|
      Streams::GrowDimension.should_grow? old_edition: item[:old_edition], attrs: item[:attrs]
    end
    items_to_grow.each do |item|
      update_edition(item[:attrs], item[:old_edition], publishing_api_event)
    end
  end

private

  def update_edition(new_edition_attr, old_edition, publishing_api_event)
    parent_warehouse_id = new_edition_attr[:parent_warehouse_id]
    attributes = new_edition_attr.except(:parent_warehouse_id).merge(publishing_api_event:)
    new_edition = Dimensions::Edition.new(attributes)
    new_edition.facts_edition = Etl::Edition::Processor.process(old_edition, new_edition)
    new_edition.promote!(old_edition)
    Streams::ParentChild::LinksProcessor.update_parent_and_sort_siblings(new_edition, parent_warehouse_id)
    new_edition
  end

  def update_existing_edition(attributes, existing_edition)
    parent_warehouse_id = attributes[:parent_warehouse_id]
    attributes = attributes.except(:parent_warehouse_id)

    existing_edition.update!(attributes)

    Streams::ParentChild::LinksProcessor
      .update_parent_and_sort_siblings(existing_edition, parent_warehouse_id)
  end
end

class Streams::ParentChild::LinksProcessor
  def self.update_parent_and_sort_siblings(edition, parent_warehouse_id)
    new(edition, parent_warehouse_id).update_parent_and_sort_siblings
  end

  def initialize(edition, parent_warehouse_id)
    @edition = edition
    @parent_warehouse_id = parent_warehouse_id
  end

  def update_parent_and_sort_siblings
    children = get_children
    update_parent_and_sort(children) unless children.empty?
    parent = get_parent
    Streams::ParentChild::LinksProcessor.update_parent_and_sort_siblings(parent, nil) unless parent.nil?
  end

private

  attr_reader :edition, :parent_warehouse_id

  def get_children
    Dimensions::Edition.where(warehouse_item_id: edition.child_sort_order, live: true)
  end

  def get_parent
    Dimensions::Edition.where(warehouse_item_id: parent_warehouse_id).first
  end

  def update_parent_and_sort(children)
    children.each do |child|
      child.update_attributes(parent: @edition, sibling_order: sort_order_for(child.warehouse_item_id))
    end
  end

  def sort_order_for(warehouse_item_id)
    edition.child_sort_order.find_index(warehouse_item_id) + 1
  end
end

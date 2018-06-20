class PublishingAPI::ItemHandler
  def initialize(old_item:, new_item:, subpage:)
    @old_item = old_item
    @new_item = new_item
    @subpage = subpage

    # old_item may be nil if the item belongs to a brand new document
    # new_item may be nil if a base_path is reused for a different content id
    raise ArgumentError if old_item.nil? && new_item.nil?
  end

  def process!
    if new_item
      grow_dimension! if new_version?
    else
      deprecate_only!
    end
  end

  def process_links!
    if new_item
      grow_dimension! if new_version? && links_have_changed?
    else
      deprecate_only!
    end
  end

private

  attr_reader :old_item
  attr_reader :new_item
  attr_reader :subpage

  def new_version?
    new_item && new_item.newer_than?(old_item)
  end

  def links_have_changed?
    return true if old_item.nil?

    HashDiff::Comparison.new(
      old_item.expanded_links.deep_sort,
      new_item.expanded_links.deep_sort
    ).diff.present?
  end

  def grow_dimension!
    new_item.promote!(old_item)
    Item::Processor.run(new_item, Date.today, subpage: subpage)
  end

  def deprecate_only!
    old_item.deprecate!
  end
end

class PublishingAPI::ItemHandler
  def initialize(old_item:, new_item:)
    @old_item = old_item
    @new_item = new_item
  end

  def process!
    promotion = PublishingAPI::Promotion.new(new_item, old_item)
    if promotion.valid?
      grow_dimension!
    end
  end

private

  attr_reader :old_item
  attr_reader :new_item

  def grow_dimension!
    new_item.promote!(old_item)
    Etl::Item::Processor.run(new_item, old_item, Date.today)
  end
end

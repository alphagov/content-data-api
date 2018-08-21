class PublishingAPI::Promotion
  def initialize(new_item, old_item)
    @new_item = new_item
    @old_item = old_item || NullItem.new
  end

  def valid?
    list = %w(id update_at created_at latest)
    attributes1 = new_item.attributes.except(*list)
    attributes2 = old_item.attributes.except(*list)

    attributes1 != attributes2
  end

private

  attr_reader :new_item, :old_item

  class NullItem
    def attributes
      {}
    end
  end
end

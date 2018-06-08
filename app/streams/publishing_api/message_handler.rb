class PublishingAPI::MessageHandler
  def self.process(message)
    new_item = PublishingAPI::MessageAdapter.to_dimension_item(message)
    old_item = Dimensions::Item.find_by(
      base_path: new_item.base_path,
      latest: true
    )

    if new_item.older_than?(old_item)
      new_item.promote!(old_item)
    end
  end
end

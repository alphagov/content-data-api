class PublishingAPI::BulkImportConsumer
  def process(message)
    content_item = PublishingAPI::ContentItem.parse_message(message.payload)
    metadata = content_item.metadata

    # When preloading data, we always create an item
    begin
      item = Dimensions::Item.create(
        latest: true,
        content_id: content_item.content_id,
        base_path: content_item.base_path,
        locale: content_item.locale,
        publishing_api_payload_version: content_item.payload_version,
        raw_json: message,
        **metadata
      )
    rescue ActiveRecord::RecordNotUnique
      logger.info "Ignoring duplicate item with content id #{content_item.content_id}. Payload version is #{content_item.payload_version}"
      return
    end

    # Do the rest of the import
    Items::Importers::ContentDetails.run(item.id, current_date.day, current_date.month, current_date.year)

    message.ack
  rescue StandardError => e
    GovukError.notify(e)
    message.discard
  end

private

  def current_date
    Time.zone.now.to_date
  end
end

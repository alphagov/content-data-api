module PublishingAPI
  class MessageValidator
    def self.is_old_message?(message)
      payload_version = message.payload.fetch('payload_version').to_i
      locale = message.payload.fetch('locale')
      content_id = message.payload.fetch('content_id')

      payload_version <= Dimensions::Item.where(
        content_id: content_id,
        locale: locale
      ).maximum('publishing_api_payload_version').to_i
    end
  end
end

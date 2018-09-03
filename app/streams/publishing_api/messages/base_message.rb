class PublishingAPI::Messages::BaseMessage
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def is_old_message?
    payload_version = @payload.fetch('payload_version').to_i
    locale = @payload.fetch('locale', nil)
    content_id = @payload.fetch('content_id')

    payload_version <= Dimensions::Item.where(
      content_id: content_id,
      locale: locale
    ).maximum('publishing_api_payload_version').to_i
  end
end
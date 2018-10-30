class PublishingAPI::Messages::BaseMessage
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def invalid?
    mandatory_fields = @payload.values_at('base_path', 'schema_name')
    mandatory_fields.any?(&:nil?)
  end

  def is_old_message?
    payload_version = @payload.fetch('payload_version').to_i
    locale = @payload.fetch('locale', nil)
    content_id = @payload.fetch('content_id')

    payload_version <= Dimensions::Edition.where(
      content_id: content_id,
      locale: locale
    ).maximum('publishing_api_payload_version').to_i
  end

  def withdrawn_notice?
    @payload.dig('withdrawn_notice', :explanation).present?
  end

  def historically_political?
    historical? && political?
  end

private

  def political?
    @payload.dig('details', 'political') || false
  end

  def historical?
    @payload.dig('details', 'government').present? && !@payload.dig('details', 'government', 'current')
  end
end

require 'active_support/concern'

module PublishingAPI::Messages::Concerns::MessageValidation
  extend ActiveSupport::Concern

  included do
    def is_old_message?
      payload_version = self.payload.fetch('payload_version').to_i
      locale = self.payload.fetch('locale', nil)
      content_id = self.payload.fetch('content_id')

      payload_version <= Dimensions::Item.where(
        content_id: content_id,
        locale: locale
      ).maximum('publishing_api_payload_version').to_i
    end
  end
end

module PublishingAPI
  class Consumer
    def process(message)
      if is_invalid_message?(message)
        GovukError.notify(StandardError.new, extra: { payload: message.payload })
        message.discard
        return
      end

      PublishingAPI::MessageHandler.process(message)

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def is_invalid_message?(message)
      mandatory_fields = message.payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end
  end
end

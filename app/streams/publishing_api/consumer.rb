module PublishingAPI
  class Consumer
    def process(message)
      if is_invalid_message?(message)
        message.discard
      else
        do_process(message)
      end
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def do_process(message)
      ActiveRecord::Base.transaction do
        PublishingAPI::MessageHandler.process(message)
        message.ack
      end
    end

    def is_invalid_message?(message)
      mandatory_fields = message.payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end
  end
end

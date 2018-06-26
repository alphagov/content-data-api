module PublishingAPI
  class Consumer
    def process(message)
      event = track_event(message)

      if is_invalid_message?(message)
        message.discard
      else
        do_process(event, message)
      end
    end

  private

    def do_process(event, message)
      PublishingAPI::MessageHandler.process(event)

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

    def is_invalid_message?(event)
      mandatory_fields = event.payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end

    def track_event(event)
      PublishingApiEvent.create!(
        payload: event.payload,
        routing_key: event.delivery_info.routing_key,
      )
    end
  end
end

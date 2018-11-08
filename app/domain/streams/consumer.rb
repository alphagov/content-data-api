module Streams
  class Consumer
    def process(message)
      if valid_message?(message)
        Streams::MessageProcessorJob.perform_later(message.payload, message.delivery_info.routing_key)
      else
        Monitor::Messages.increment_discarded
      end

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def valid_message?(message)
      valid_routing_key?(message) &&
        valid_schema?(message)
    end

    def valid_schema?(message)
      !message.payload['schema_name'].include?('placeholder')
    end

    def valid_routing_key?(message)
      routing_key = message.delivery_info.routing_key

      ROUTING_KEYS.any? { |suffix| routing_key.ends_with?(suffix) }
    end

    ROUTING_KEYS = %w(links major minor unpublish bulk.data-warehouse).freeze
  end
end

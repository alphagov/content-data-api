require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe 'Process all schemas' do

  let(:subject) { PublishingAPI::Consumer.new }

  before do
    allow(GovukError).to receive(:notify)
  end

  SchemasIterator.each_schema do |schema_name, schema|
    unless %w{travel_advice guide}.include?(schema_name) || schema_name.include?('placeholder')
      %w{major minor links republish unpublish}.each do |update_type|
        it "handles event for: `#{schema_name}` with no errors for a `#{update_type}` update" do
          payload = SchemasIterator.payload_for(schema_name, schema)
          message = build(:message, payload: payload, routing_key: "#{schema_name}.#{update_type}")

          subject.process(message)

          expect(GovukError).not_to have_received(:notify)
        end
      end
    end
  end
end

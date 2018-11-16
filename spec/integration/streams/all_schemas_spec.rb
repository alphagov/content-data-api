require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe 'Process all schemas' do
  let(:subject) { Streams::Consumer.new }

  SchemasIterator.each_schema do |schema_name, schema|
    next if schema_name == 'redirect'
    %w{major minor links republish unpublish}.each do |update_type|
      it "handles event for: `#{schema_name}` with no errors for a `#{update_type}` update" do
        expect(GovukError).not_to receive(:notify)

        payload = SchemasIterator.payload_for(schema_name, schema)
        message = build(:message, payload: payload, routing_key: "#{schema_name}.#{update_type}")
        subject.process(message)
      end
    end
  end

  describe 'redirect schema' do
    let(:schema) { GovukSchemas::Schema.find(notification_schema: 'redirect') }
    let(:message) { build(:redirect_message) }

    it 'handles events for redirect with no errors for republish update' do
      expect(GovukError).not_to receive(:notify)

      subject.process(message)
    end
  end
end

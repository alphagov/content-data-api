require "govuk_message_queue_consumer/test_helpers"

RSpec.describe "Process all schemas" do
  let(:subject) { Streams::Consumer.new }

  SchemasIterator.each_schema do |schema_name, schema|
    it "has a parser for #{schema_name}" do
      expect(Etl::Edition::Content::Parser.new.send(:for_schema, schema_name)).not_to be_nil
    end

    %w[major minor links republish unpublish].each do |update_type|
      it "handles event for: `#{schema_name}` with no errors for a `#{update_type}` update" do
        expect(GovukError).not_to receive(:notify)

        payload = SchemasIterator.payload_for(schema_name, schema)
        message = build(:message, payload:, routing_key: "#{schema_name}.#{update_type}")

        subject.process(message)
      end
    end
  end
end

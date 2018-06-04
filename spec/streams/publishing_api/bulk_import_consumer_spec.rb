require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingAPI::BulkImportConsumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'
end

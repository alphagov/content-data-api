require 'rails_helper'
require 'publishing_api/publishing_api_bulk_import_consumer'
require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingAPI::PublishingApiBulkImportConsumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'
end

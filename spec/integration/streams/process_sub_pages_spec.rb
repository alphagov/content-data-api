require 'govuk_message_queue_consumer/test_helpers/mock_message'

RSpec.describe "Process sub-pages for multipart content types" do
  include QualityMetricsHelpers

  let(:subject) { PublishingAPI::Consumer.new }

  before { stub_quality_metrics }

  it "grows dimension for each subpage" do
    expect {
      subject.process(build(:message, :with_parts))
    }.to change(Dimensions::Item, :count).by(4)
  end

  # TODO: Tests for
  # ✅ creates new dimensions for an existing multipage content item
  # adding a subpage
  # removing a subpage
  # renaming a basepath of a subpage
  # promotes each
  # demotes each
end

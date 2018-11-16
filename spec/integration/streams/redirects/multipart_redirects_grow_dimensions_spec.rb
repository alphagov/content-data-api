require 'govuk_message_queue_consumer/test_helpers/mock_message'

RSpec.describe "Process redirect sub-pages for multipart content types" do
  include PublishingEventProcessingSpecHelper

  let(:subject) { Streams::Consumer.new }
  let(:content_id) { SecureRandom.uuid }

  it "grows the dimension for each subpage" do
    message = build(:message, :with_parts, base_path: '/base-path', payload_version: 2, attributes: {
      'content_id' => content_id,
      'locale' => 'en',
      'title' => 'Main Title'
    })

    redirect_part_message = build :redirect_message, base_path: '/base-path/part2'

    subject.process(message)
    subject.process(redirect_part_message)

    part_edition = Dimensions::Edition.find_by(base_path: '/base-path/part2')
    expect(part_edition.document_type).to eq('redirect')
  end
end

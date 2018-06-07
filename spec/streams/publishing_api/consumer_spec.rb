require 'sidekiq/testing'
require 'govuk_message_queue_consumer/test_helpers'
require 'gds_api/test_helpers/content_store'

RSpec.describe PublishingAPI::Consumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  context 'when an error happens' do
    let!(:message) do
      double('message',
        payload: {
          'base_path' => '/path/to/new/content',
          'content_id' => 'the_content_id',
          'payload_version' => 1,
          'expanded_links' => {},
          'details' => {}
        },
        delivery_info: double('del_info', routing_key: 'news_story.major'))
    end

    before do
      allow(message).to receive(:discard)
      expect(subject).to receive(:do_process).and_raise(StandardError.new("An error"))
    end

    it "logs the error" do
      expect(GovukError).to receive(:notify).with(instance_of(StandardError))

      expect { subject.process(message) }.to_not raise_error
    end

    it "discards the message" do
      expect(message).to receive(:discard)

      subject.process(message)
    end
  end
end

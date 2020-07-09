require "govuk_message_queue_consumer/test_helpers"

def expect_messages_to_have_publishing_api_events(messages)
  expected_messages = messages.map do |message|
    have_attributes(
      routing_key: message.delivery_info["routing_key"],
      payload: message.payload,
    )
  end
  expect(Events::PublishingApi.all).to contain_exactly(*expected_messages)
end

RSpec.describe "PublishingAPI message queue" do
  # FIXME: Rails 6 inconsistently overrides ActiveJob queue_adapter setting
  # with TestAdapter #37270
  # See https://github.com/rails/rails/issues/37270
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  include PublishingEventProcessingSpecHelper

  let(:subject) { Streams::Consumer.new }

  it "publishes new edition for new content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major")

    message = build :message
    subject.process(message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{message.payload['content_id']}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message])
    expect(message).to be_acked
  end

  it "publishes multiple editions for a content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message1 = build :message
    subject.process(message1)

    content_id = message1.payload["content_id"]

    message2 = build :message, content_id: content_id
    subject.process(message2)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message1, message2])
    expect(message1).to be_acked
    expect(message2).to be_acked
  end

  it "republishes same edition for content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message = build :message
    subject.process(message)
    subject.process(message)

    content_id = message.payload["content_id"]

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message])
    expect(message).to be_acked
  end

  it "sends an old publishing message" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message = build :message, attributes: { "payload_version" => 2 }
    subject.process(message)

    content_id = message.payload["content_id"]

    old_message = build :message, content_id: content_id, attributes: { "payload_version" => 1 }
    subject.process(old_message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message])
    expect(message).to be_acked
    expect(old_message).to be_acked
  end

  it "unpublishes edition for content item" do
    expect(GovukStatsd).to receive(:increment)
     .with("monitor.messages.major").twice

    message = build :message
    subject.process(message)

    content_id = message.payload["content_id"]

    gone_message = build :gone_message, content_id: content_id
    subject.process(gone_message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "gone",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
    )

    expect_messages_to_have_publishing_api_events([message, gone_message])
    expect(message).to be_acked
    expect(gone_message).to be_acked
  end

  it "twice unpublishes edition for content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").exactly(3).times

    message = build :message
    subject.process(message)

    content_id = message.payload["content_id"]

    gone_message1 = build :gone_message, content_id: content_id
    subject.process(gone_message1)

    gone_message2 = build :gone_message, content_id: content_id
    subject.process(gone_message2)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "gone",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
    )

    expect_messages_to_have_publishing_api_events([message, gone_message1])
    expect(message).to be_acked
    expect(gone_message1).to be_acked
    expect(gone_message2).to be_acked
  end

  it "publishes redirect edition for content item" do
    expect(GovukStatsd).to receive(:increment)
     .with("monitor.messages.major").twice

    message = build :message
    subject.process(message)

    content_id = message.payload["content_id"]

    redirect_message = build :redirect_message, content_id: content_id
    subject.process(redirect_message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "redirect",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
    )

    expect_messages_to_have_publishing_api_events([message, redirect_message])
    expect(message).to be_acked
    expect(redirect_message).to be_acked
  end

  it "publishes edition with new base_path for content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message1 = build :message
    subject.process(message1)

    content_id = message1.payload["content_id"]

    message2 = build :message, content_id: content_id, base_path: "/base-path-2"
    subject.process(message2)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path-2",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message1, message2])
    expect(message1).to be_acked
    expect(message2).to be_acked
  end

  it "publishes new content item using base path of previously unpublished content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").exactly(3).times

    message1 = build :message
    subject.process(message1)

    content_id = message1.payload["content_id"]

    gone_message = build :gone_message, content_id: content_id
    subject.process(gone_message)

    message2 = build :message
    subject.process(message2)

    content_id2 = message2.payload["content_id"]

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "gone",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id2}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message1, gone_message, message2])
    expect(message1).to be_acked
    expect(gone_message).to be_acked
    expect(message2).to be_acked
  end
end

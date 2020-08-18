require "govuk_message_queue_consumer/test_helpers"

RSpec.describe Streams::Consumer do
  # FIXME: Rails 6 inconsistently overrides ActiveJob queue_adapter setting
  # with TestAdapter #37270
  # See https://github.com/rails/rails/issues/37270
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  include PublishingEventProcessingSpecHelper

  let(:subject) { described_class.new }

  it "does not grow the dimension if the event carries no changes in an attribute" do
    message = build :message, base_path: "/base-path", attributes: { "payload_version" => 2 }
    message2 = build :message, payload: message.payload.dup
    message2.payload["payload_version"] = 4

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Edition, :count).by(1)
  end

  context "when the event carries a change" do
    it "deprecates old editions" do
      message = build :message, base_path: "/base-path", attributes: { "payload_version" => 2 }
      message2 = build :message, payload: message.payload.dup
      message2.payload["payload_version"] = 4
      message2.payload["title"] = "updated-title"

      expect {
        subject.process(message)
        subject.process(message2)
      }.to change(Dimensions::Edition, :count).by(2)

      expect(Dimensions::Edition.find_by(publishing_api_payload_version: 2)).to have_attributes(live: false)
      expect(Dimensions::Edition.find_by(publishing_api_payload_version: 4)).to have_attributes(live: true)
    end

    it "grows the dimension" do
      message = build :message, base_path: "/base-path", attributes: { "payload_version" => 2 }
      message2 = build :message, payload: message.payload.deep_dup
      message2.payload["payload_version"] = 4
      message2.payload["details"]["body"] = "<p>different content</p>"
      expect {
        subject.process(message)
        subject.process(message2)
      }.to change(Dimensions::Edition, :count).by(2)
    end

    it "updates the attributes correctly" do
      message = build :message, base_path: "/base-path", attributes: message_attributes
      message.payload["details"]["body"] = "<p>some content</p>"
      subject.process(message)
      live_edition = Dimensions::Edition.live.find_by(base_path: "/base-path")
      expect(live_edition).to have_attributes(expected_edition_attributes(content_id: message.payload["content_id"]))
    end

    it "assigns the same warehouse_item_id to the new edition" do
      content_id = SecureRandom.uuid

      message = build :message, base_path: "/base-path", content_id: content_id, attributes: { "payload_version" => 2 }
      subject.process(message)

      message2 = build :message, content_id: content_id, payload: message.payload.deep_dup
      message2.payload["payload_version"] = 4
      message2.payload["details"]["body"] = "<p>different content</p>"
      subject.process(message2)

      warehouse_ids = Dimensions::Edition.where(base_path: "/base-path").pluck(:warehouse_item_id)
      expect(warehouse_ids.uniq).to eq(["#{content_id}:en"])
    end
  end

  context "when the message is for an organisation" do
    it "assigns the acronym" do
      message = build :message, base_path: "/base-path", attributes: message_attributes
      message.payload["details"]["acronym"] = "HMRC"
      subject.process(message)

      live_edition = Dimensions::Edition.live.find_by(base_path: "/base-path")
      expect(live_edition).to have_attributes(acronym: "HMRC")
    end
  end
end

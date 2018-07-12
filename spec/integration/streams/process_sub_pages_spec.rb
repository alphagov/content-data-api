require 'govuk_message_queue_consumer/test_helpers/mock_message'

RSpec.describe "Process sub-pages for multipart content types" do
  include QualityMetricsHelpers

  let(:subject) { PublishingAPI::Consumer.new }

  before { stub_quality_metrics }

  it "grows the dimension for each subpage" do
    message = build(:message, :with_parts)

    expect {
      subject.process(message)
    }.to change(Dimensions::Item, :count).by(4)
  end

  it "separates the parts of multipart content types" do
    message = build(:message, :with_parts)
    subject.process(message)

    parts = Dimensions::Item.pluck(:base_path, :title).to_set

    expect(parts).to eq Set[
      ["/base-path", "Part 1"],
      ["/base-path/part2", "Part 2"],
      ["/base-path/part3", "Part 3"],
      ["/base-path/part4", "Part 4"]
    ]
  end

  it "deprecates all existing parts even if only one item changed" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload["details"]["parts"][1]["body"] = "this is a change"
    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Item.count).to eq(8)
    expect(Dimensions::Item.where(latest: true).count).to eq(4)
  end

  it "increases the number of latest items when a subpage is added" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload.dig("details", "parts") << {
      "title" => "New thing",
      "slug" => "new-thing",
      "body" => [
        {
          "content_type" => "text/govspeak",
          "content" => "New thing"
        }
      ]
    }

    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Item.count).to eq(9)
    expect(Dimensions::Item.where(latest: true).count).to eq(5)
  end

  it "decreases the number of latest items when a subpage is removed" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload.dig("details", "parts").pop
    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Item.count).to eq(7)
    expect(Dimensions::Item.where(latest: true).count).to eq(3)
  end

  it "still grows the dimension if parts are renamed" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload.dig("details", "parts").first["slug"] = "new-slug"
    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Item.count).to eq(8)
    expect(Dimensions::Item.where(latest: true).count).to eq(4)
  end

  context "when base paths in the message already belong to items with a different content id" do
    it "deprecates the clashing items" do
      message = build(:message, :with_parts)
      message.payload["content_id"] = "df9b33a8-73ae-4504-91a1-4a397cf1f3c5"
      message.payload["base_path"] = "/some-url"
      subject.process(message)

      another_message = build(:message, :with_parts)
      another_message.payload["content_id"] = "db3df7bc-4315-496a-b3b7-4f0e705a2c1f"
      another_message.payload["base_path"] = "/some-url"
      subject.process(another_message)

      expect(Dimensions::Item.count).to eq(8)
      expect(Dimensions::Item.where(latest: true).count).to eq(4)
    end
  end

  context "when multi part content types have different first parts" do
    multipart_types = Etl::Item::Content::Parsers::Parts.new.schemas

    multipart_types.each do |type|
      context type do
        it "it creates an item with base path and no slug for first part" do
          message = build(:message, type.to_sym)
          message.payload["base_path"] = "/#{type}-url"
          subject.process(message)

          item = Dimensions::Item.where(base_path: "/#{type}-url", latest: true).first
          part = Dimensions::Item.where(base_path: "/#{type}-url/part2", latest: true).first

          expect(item.base_path).to eq("/#{type}-url")
          expect(part.base_path).to eq("/#{type}-url/part2")
        end
      end
    end
  end

  context "different schemas structure first part differently" do
    it "extracts the content for travel advice" do
      message = build(:message, :travel_advice)
      message.payload["base_path"] = "/travel-advice"
      message.payload["details"]["summary"] = [
          "content_type" => "text/html",
          "content" => 'Summary content'
      ]
      subject.process(message)

      item = Dimensions::Item.where(base_path: "/travel-advice", latest: true).first

      expect(item.document_text).to eq("Summary content")
    end

    it "extracts the content for guide" do
      message = build(:message, :guide)
      message.payload["base_path"] = "/guide"
      message.payload["details"]["parts"] = [
        {
          "title" => "Guide 1",
          "slug" => "/guide",
          "body" => [
            {
              "content_type" => "text/html",
              "content" => "<h1>Heading 1</h1>"
            }
          ]
        }
      ]
      subject.process(message)

      item = Dimensions::Item.where(base_path: "/guide", latest: true).first

      expect(item.document_text).to eq("Heading 1")
    end
  end
end

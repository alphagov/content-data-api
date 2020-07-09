require "govuk_message_queue_consumer/test_helpers/mock_message"

RSpec.describe "Process sub-pages for multipart content types" do
  # FIXME: Rails 6 inconsistently overrides ActiveJob queue_adapter setting
  # with TestAdapter #37270
  # See https://github.com/rails/rails/issues/37270
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  include PublishingEventProcessingSpecHelper

  let(:subject) { Streams::Consumer.new }

  it "grows the dimension for each subpage" do
    message = build(:message, :with_parts)

    expect {
      subject.process(message)
    }.to change(Dimensions::Edition, :count).by(4)
  end

  it "grows the publishing api events with message" do
    message = build(:message, :with_parts)

    expect {
      subject.process(message)
    }.to change(Events::PublishingApi, :count).by(1)
  end

  context "for a guide" do
    let(:content_id) { "3079e1a9-4b07-4012-af68-8b86f918fae9" }

    it "separates the parts of multipart content types with different uuids" do
      message = build(
        :message,
        :with_parts,
        attributes: {
          "content_id" => content_id,
          "locale" => "en",
          "title" => "Main Title",
        },
      )
      subject.process(message)

      parts = Dimensions::Edition.pluck(:base_path, :title, :warehouse_item_id).to_set

      expect(parts).to eq Set[
        ["/base-path", "Main Title: Part 1", "#{content_id}:en"],
        ["/base-path/part2", "Main Title: Part 2", "#{content_id}:en:part2"],
        ["/base-path/part3", "Main Title: Part 3", "#{content_id}:en:part3"],
        ["/base-path/part4", "Main Title: Part 4", "#{content_id}:en:part4"]
      ]
    end
  end

  context "for travel advice" do
    let(:content_id) { "fefbf6af-8510-432d-8126-c1bf11fadec1" }
    it "separates the parts of multipart content types with different uuids" do
      message = build(
        :message,
        :travel_advice,
        base_path: "/travel/advice",
        content_id: content_id,
        locale: "fr",
        attributes: {
          "title" => "The Title",
        },
      )
      subject.process(message)
      parts = Dimensions::Edition.pluck(:base_path, :title, :warehouse_item_id).to_set

      expect(parts).to eq Set[
        ["/travel/advice", "The Title: Summary", "#{content_id}:fr"],
        ["/travel/advice/part1", "The Title: Part 1", "#{content_id}:fr:part1"],
        ["/travel/advice/part2", "The Title: Part 2", "#{content_id}:fr:part2"],
      ]
    end
  end

  it "deprecates only the parts that have changed" do
    message = build(:message, :with_parts)
    subject.process(message)
    expect(Dimensions::Edition.count).to eq(4)

    message.payload["details"]["parts"][1]["body"] = "this is a change"
    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Edition.count).to eq(5)
    expect(Dimensions::Edition.live.count).to eq(4)
  end

  it "increases the number of live items when a subpage is added" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload.dig("details", "parts") << {
      "title" => "New thing",
      "slug" => "new-thing",
      "body" => [
        {
          "content_type" => "text/govspeak",
          "content" => "New thing",
        },
      ],
    }

    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Edition.count).to eq(6)
    expect(Dimensions::Edition.live.count).to eq(5)
  end

  it "decreases the number of live items when a subpage is removed" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload.dig("details", "parts").pop
    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Edition.count).to eq(5)
    expect(Dimensions::Edition.live.count).to eq(3)
  end

  it "still grows the dimension if parts are renamed" do
    message = build(:message, :with_parts)
    subject.process(message)

    message.payload.dig("details", "parts")[1]["slug"] = "new-slug"
    message.payload["payload_version"] = message.payload["payload_version"] + 1

    subject.process(message)

    expect(Dimensions::Edition.count).to eq(6)
    expect(Dimensions::Edition.live.count).to eq(4)
  end

  context "when multi part content types have different first parts" do
    multipart_types = Etl::Edition::Content::Parsers::Parts.new.schemas

    multipart_types.each do |type|
      context type do
        it "it creates an edition with base path and no slug for first part" do
          message = build(:message, type.to_sym)
          message.payload["base_path"] = "/#{type}-url"
          subject.process(message)

          edition = Dimensions::Edition.where(base_path: "/#{type}-url", live: true).first
          part = Dimensions::Edition.where(base_path: "/#{type}-url/part2", live: true).first

          expect(edition.base_path).to eq("/#{type}-url")
          expect(part.base_path).to eq("/#{type}-url/part2")
        end
      end
    end
  end

  shared_examples "when unchanged" do
    it "does not grow the dimension" do
      message2 = build :message, payload: message.payload.dup
      message2.payload["payload_version"] = message.payload["payload_version"] + 1

      expect { subject.process(message2) }.not_to change(Dimensions::Edition, :count)
    end
  end

  context "when the content is `travel_advice`" do
    let(:message) do
      build :message,
            :travel_advice,
            attributes: message_attributes(
              "base_path" => "/travel-advice",
              "content_id" => "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
              "document_type" => "travel_advice",
            ),
            summary: "Summary content"
    end

    before do
      create :edition,
             base_path: "/travel-advice/part3",
             content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
             locale: "fr",
             publishing_api_payload_version: 0
      allow(GovukError).to receive(:notify)
      subject.process(message)
    end

    it_behaves_like "when unchanged"

    it "extracts the Summary" do
      item = Dimensions::Edition.where(base_path: "/travel-advice", live: true).first
      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/travel-advice",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "Summary content",
                                        document_type: "travel_advice",
                                        schema_name: "travel_advice",
                                        title: "the-title: Summary",
                                      ))
    end

    it "extracts /travel-advice/part1" do
      item = Dimensions::Edition.where(base_path: "/travel-advice/part1", live: true).first

      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/travel-advice/part1",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "Here 1",
                                        document_type: "travel_advice",
                                        schema_name: "travel_advice",
                                        title: "the-title: Part 1",
                                      ))
    end

    it "extracts /travel-advice/part2" do
      item = Dimensions::Edition.where(base_path: "/travel-advice/part2", live: true).first
      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/travel-advice/part2",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "be 2",
                                        document_type: "travel_advice",
                                        schema_name: "travel_advice",
                                        title: "the-title: Part 2",
                                      ))
    end

    it "deprecates any other items" do
      query = Dimensions::Edition.where(base_path: "/travel-advice/part3")
      expect(query.count).to eq(1)
      expect(query.first.live).to eq(false)
    end

    it "does not log any errors" do
      expect(GovukError).not_to have_received(:notify)
    end
  end

  context "when the content is a `guide`" do
    let(:message) do
      build(
        :message,
        :with_parts,
        base_path: "/guide",
        attributes: message_attributes(
          "base_path" => "/guide",
          "content_id" => "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
          "document_type" => "guide",
        ),
      )
    end

    before do
      create :edition,
             base_path: "/guide/part5",
             content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
             locale: "fr",
             publishing_api_payload_version: 0,
             title: "the-title: Part 5"
      allow(GovukError).to receive(:notify)
      subject.process(message)
    end

    it_behaves_like "when unchanged"

    it "extracts part 1 on the base path" do
      item = Dimensions::Edition.where(base_path: "/guide", live: true).first
      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/guide",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "Here 1",
                                        document_type: "guide",
                                        schema_name: "guide",
                                        title: "the-title: Part 1",
                                      ))
    end

    it "extracts part 2 under the base path" do
      item = Dimensions::Edition.where(base_path: "/guide/part2", live: true).first
      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/guide/part2",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "be 2",
                                        document_type: "guide",
                                        schema_name: "guide",
                                        title: "the-title: Part 2",
                                      ))
    end

    it "extracts part 3 under the base path" do
      item = Dimensions::Edition.where(base_path: "/guide/part3", live: true).first
      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/guide/part3",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "some 3",
                                        document_type: "guide",
                                        schema_name: "guide",
                                        title: "the-title: Part 3",
                                      ))
    end

    it "extracts part 4 under the base path" do
      item = Dimensions::Edition.where(base_path: "/guide/part4", live: true).first
      expect(item).to have_attributes(expected_edition_attributes(
                                        base_path: "/guide/part4",
                                        content_id: "12123d8e-1a8b-42fd-ba93-c953ad20bc8a",
                                        document_text: "content 4.",
                                        document_type: "guide",
                                        schema_name: "guide",
                                        title: "the-title: Part 4",
                                      ))
    end

    it "deprecates any other items" do
      query = Dimensions::Edition.where(base_path: "/guide/part5")
      expect(query.count).to eq(1)
      expect(query.first.live).to eq(false)
    end

    it "does not log any errors" do
      expect(GovukError).not_to have_received(:notify)
    end
  end
end

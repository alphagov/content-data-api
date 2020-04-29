RSpec.describe Streams::Messages::SingleItemMessage do
  include PublishingEventProcessingSpecHelper

  subject { described_class }

  include_examples "BaseMessage#invalid?"
  include_examples "BaseMessage#organisation_ids"
  include_examples "BaseMessage#historically_political?"
  include_examples "BaseMessage#withdrawn_notice?"

  let(:instance) { subject.new(message.payload, "routing_key") }

  describe "#edition_attributes" do
    let(:message) do
      msg = build(:message, attributes: message_attributes)
      msg.payload["details"]["body"] = "<p>some content</p>"
      msg.payload["details"]["government"] = { "current" => true }
      msg.payload["withdrawn_notice"] = { "explanation" => "something" }
      msg
    end

    it "returns the attributes" do
      attributes = instance.edition_attributes
      expect(attributes).to eq(
        expected_raw_attributes(
          content_id: message.payload["content_id"],
          document_text: "some content",
          historical: false,
          warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}",
          withdrawn: true,
          acronym: nil,
        ),
      )
    end
  end

  describe "extracts Organisation's acronym" do
    let(:message) do
      msg = build(:message, attributes: message_attributes)
      subject.new(msg.payload, "routing_key")
    end

    it "assigns the acronym if provided" do
      message.payload["details"]["acronym"] = "HMRC"
      attributes = message.edition_attributes

      expect(attributes).to include(acronym: "HMRC")
    end

    it "does not assign a value when empty string" do
      message.payload["details"]["acronym"] = ""
      attributes = message.edition_attributes

      expect(attributes).to include(acronym: nil)
    end

    it "does not assigns a value if not provided" do
      message.payload["details"].delete "acronym"
      attributes = message.edition_attributes

      expect(attributes).to include(acronym: nil)
    end
  end

  describe "documents with links > parent/children" do
    let(:message) { build :message }

    before do
      message.payload["expanded_links"] = links
      message.payload["schema_name"] = "publication"
      message.payload["document_type"] = "guidance"
    end

    context "when parent/child links exist" do
      let(:links) do
        {
          "children" => [
            { "content_id" => "child-1-id", "locale" => "en" },
            { "content_id" => "child-2-id", "locale" => "en" },
          ],
          "parent" => [{ "content_id" => "parent-id", "locale" => "en" }],
        }
      end

      it "extracts a list of child warehouse ids" do
        expected = [
          "child-1-id:en",
          "child-2-id:en",
        ]
        expect(instance.edition_attributes[:child_sort_order]).to eq(expected)
      end

      it "sets the parent warehouse id under temp key" do
        expect(instance.edition_attributes[:parent_warehouse_id]).to eq("parent-id:en")
      end
    end

    context "when parent/children keys are missing" do
      let(:links) { {} }

      it "returns null for parent" do
        expect(instance.edition_attributes[:parent_warehouse_id]).to be_nil
      end

      it "returns an empty array for child_sort_order" do
        expect(instance.edition_attributes[:child_sort_order]).to eq([])
      end
    end
  end

  describe "for a manual" do
    let(:message) { build :message }

    before do
      message.payload["expanded_links"] = links
      message.payload["schema_name"] = "manual"
      message.payload["document_type"] = "manual"
    end

    context "when sections exist in links" do
      let(:links) do
        {
          "sections" => [
            { "content_id" => "child-1-id", "locale" => "en" },
            { "content_id" => "child-2-id", "locale" => "en" },
          ],
        }
      end

      it "extracts a list of child warehouse ids from links > sections" do
        expected = [
          "child-1-id:en",
          "child-2-id:en",
        ]
        expect(instance.edition_attributes[:child_sort_order]).to eq(expected)
      end
    end

    context "when sections key is missing" do
      let(:links) { {} }

      it "returns an empty array for child_sort_order" do
        expect(instance.edition_attributes[:child_sort_order]).to eq([])
      end
    end
  end

  describe "for a manual section" do
    let(:message) { build :message }

    before do
      message.payload["expanded_links"] = links
      message.payload["schema_name"] = "manual_section"
      message.payload["document_type"] = "manual_section"
    end

    context "when manual exists in links" do
      let(:links) { { "manual" => [{ "content_id" => "parent-id", "locale" => "en" }] } }

      it "sets the parent warehouse id under temp key" do
        expect(instance.edition_attributes[:parent_warehouse_id]).to eq("parent-id:en")
      end
    end

    context "when manual key is missing" do
      let(:links) { {} }

      it "returns null for parent" do
        expect(instance.edition_attributes[:parent_warehouse_id]).to be_nil
      end
    end
  end
end

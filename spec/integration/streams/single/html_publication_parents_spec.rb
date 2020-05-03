RSpec.describe "setting parents for html_publications" do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:parent_message) do
    build :message,
          base_path: "/parent",
          schema_name: "publication",
          attributes: {
            "document_type" => "guidance",
          }
  end

  let(:attachment_1_message) do
    build :message,
          base_path: "/parent/child/1",
          schema_name: "html_publication",
          attributes: { "document_type" => "html_publication" }
  end

  let(:attachment_2_message) do
    build :message,
          base_path: "/parent/child/2",
          schema_name: "html_publication",
          attributes: { "document_type" => "html_publication" }
  end
  let(:links_for_parent) do
    {
      "children" => [attachment_1_message, attachment_2_message].map do |message|
        { "content_id" => message.payload["content_id"], "locale" => message.payload["locale"] }
      end,
    }
  end
  let(:links_for_child) do
    { "parent" => [{
      "content_id" => parent_message.payload["content_id"],
      "locale" => parent_message.payload["locale"],
    }] }
  end
  subject { Streams::Consumer.new }

  before do
    parent_message.payload["expanded_links"] = links_for_parent
    attachment_1_message.payload["expanded_links"] = links_for_child
    attachment_2_message.payload["expanded_links"] = links_for_child
  end

  context "when the parent arrives first" do
    before do
      subject.process(parent_message)
      subject.process(attachment_2_message)
      subject.process(attachment_1_message)
    end

    it "sets the parents correctly" do
      parent_warehouse_id = "#{parent_message.payload['content_id']}:#{parent_message.payload['locale']}"
      parent = Dimensions::Edition.where(warehouse_item_id: parent_warehouse_id).first
      expected = [
        ["#{attachment_1_message.payload['content_id']}:#{attachment_1_message.payload['locale']}", 1],
        ["#{attachment_2_message.payload['content_id']}:#{attachment_2_message.payload['locale']}", 2],
      ]
      expect(parent.children.order(:sibling_order).pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
    end
  end

  context "when the child messages arrive first" do
    before do
      subject.process(attachment_2_message)
      subject.process(attachment_1_message)
      subject.process(parent_message)
    end

    it "sets the parents correctly" do
      parent_warehouse_id = "#{parent_message.payload['content_id']}:#{parent_message.payload['locale']}"
      parent = Dimensions::Edition.where(warehouse_item_id: parent_warehouse_id).first
      expected = [
        ["#{attachment_1_message.payload['content_id']}:#{attachment_1_message.payload['locale']}", 1],
        ["#{attachment_2_message.payload['content_id']}:#{attachment_2_message.payload['locale']}", 2],
      ]
      expect(parent.children.order(:sibling_order).pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
    end
  end
end

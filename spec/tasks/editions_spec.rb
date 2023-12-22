RSpec.describe "rake editions:*", type: task do
  describe "update_existing" do
    it "updates edition when payload changes" do
      payload = build(:message).payload
      Streams::MessageProcessorJob.perform_now(payload, "something.major")

      edition = Dimensions::Edition.first
      edition.publishing_api_event.payload["base_path"] = "New"
      edition.publishing_api_event.save!

      Rake::Task["editions:update_existing"].invoke

      edition.reload
      expect(edition.base_path).to eq("New")
    end

    it "updates edition relationship information for multipart" do
      payload = build(:message, :with_parts).payload
      Streams::MessageProcessorJob.perform_now(payload, "something.major")

      old_editions = Dimensions::Edition.all.to_a

      Dimensions::Edition.all.find_each do |edition|
        edition.parent = nil
        edition.sibling_order = nil
        edition.child_sort_order = nil
        edition.save!
      end

      Rake::Task["editions:update_existing"].invoke

      expect(Dimensions::Edition.live.all).to match_array(old_editions)
    end

    it "updates edition relationship information for publication edition" do
      parent = build(
        :message,
        schema_name: "publication",
        document_type: "guidance",
      ).payload

      child = build(
        :message,
        schema_name: "publication",
        document_type: "guidance",
        base_path: "/child",
      ).payload

      parent["links"]["children"] = [
        { "content_id" => child["content_id"], "locale" => child["locale"] },
      ]

      child["links"]["parent"] = [
        { "content_id" => parent["content_id"], "locale" => parent["locale"] },
      ]

      Streams::MessageProcessorJob.perform_now(parent, "something.major")
      Streams::MessageProcessorJob.perform_now(child, "something.major")

      old_editions = Dimensions::Edition.all.to_a

      Dimensions::Edition.all.find_each do |edition|
        edition.parent = nil
        edition.sibling_order = nil
        edition.child_sort_order = nil
        edition.save!
      end

      Rake::Task["editions:update_existing"].invoke

      expect(Dimensions::Edition.live.all).to match_array(old_editions)
    end
  end
end

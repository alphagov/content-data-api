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

  describe "update_file_counts" do
    let(:task) { Rake::Task["editions:update_file_counts"] }

    let(:attachments_payload) do
      {
        "details" => {
          "attachments" => [
            { "filename" => "guide.pdf" },
            { "filename" => "template.docx" },
            { "filename" => "guide2.pdf" },
            { "filename" => "ignore.txt" },
          ],
        },
      }
    end

    let(:html_payload) do
      {
        "details" => {
          "body" => '<div class="attachment-details"><a href="/a/form.docm">doc</a><a href="/a/guide.pdf">pdf</a></div>',
        },
      }
    end

    let!(:live_from_attachments) do
      create(:edition,
             publishing_api_event: create(:publishing_api_event, payload: attachments_payload),
             facts: { pdf_count: 0, doc_count: 0 })
    end

    let!(:live_from_html) do
      create(:edition,
             publishing_api_event: create(:publishing_api_event, payload: html_payload),
             facts: { pdf_count: 0, doc_count: 0 })
    end

    let!(:not_live) do
      create(:edition,
             live: false,
             publishing_api_event: create(:publishing_api_event, payload: attachments_payload),
             facts: { pdf_count: 9, doc_count: 9 })
    end

    before do
      allow($stdout).to receive(:puts)
      allow(Etl::Aggregations::Search).to receive(:process)
      task.reenable
    end

    it "updates file counts from structured attachments or html fallback" do
      task.invoke

      expect(live_from_attachments.facts_edition.reload.pdf_count).to eq(2)
      expect(live_from_attachments.facts_edition.reload.doc_count).to eq(1)
      expect(live_from_html.facts_edition.reload.pdf_count).to eq(1)
      expect(live_from_html.facts_edition.reload.doc_count).to eq(1)
      expect(not_live.facts_edition.reload.pdf_count).to eq(9)
      expect(not_live.facts_edition.reload.doc_count).to eq(9)
    end

    it "calls upsert_all with the correct arguments" do
      allow(Facts::Edition).to receive(:upsert_all)

      task.invoke

      expect(Facts::Edition).to have_received(:upsert_all).once.with(
        contain_exactly(
          hash_including("id" => live_from_attachments.facts_edition.id, "dimensions_edition_id" => live_from_attachments.id, "pdf_count" => 2, "doc_count" => 1),
          hash_including("id" => live_from_html.facts_edition.id, "dimensions_edition_id" => live_from_html.id, "pdf_count" => 1, "doc_count" => 1),
        ),
      )
    end

    it "refreshes search aggregations after updating counts" do
      create(:edition, facts: { pdf_count: 0, doc_count: 0 })

      task.invoke

      expect(Etl::Aggregations::Search).to have_received(:process).once
    end
  end
end

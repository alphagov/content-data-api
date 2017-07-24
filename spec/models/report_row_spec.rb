RSpec.describe ReportRow do
  let!(:content_item) do
    create(
      :content_item,
      title: "Title",
      base_path: "/example/path",
      document_type: "travel_advice",
      public_updated_at: "2017-02-15",
      six_months_page_views: 1234,
      content_id: "id123",
      publishing_app: "whitehall",
    )
  end

  let!(:audit) { create(:audit, content_item: content_item) }

  let!(:responses) do
    Question.all.map do |question|
      create(:response, audit: audit, question: question, value: "yes")
    end
  end

  let!(:hmrc) { create(:content_item, title: "HMRC") }

  let!(:hmrc_link) do
    create(
      :link,
      source: content_item,
      target: hmrc,
      link_type: "primary_publishing_organisation",
    )
  end

  subject { described_class.precompute(content_item) }

  let(:expected_whitehall_url) { "#{WHITEHALL}/government/admin/by-content-id/id123" }

  specify { expect(subject.title).to eq                   "Title" }
  specify { expect(subject.url).to eq                     "https://gov.uk/example/path" }
  specify { expect(subject.is_work_needed).to eq          "Yes" }
  specify { expect(subject.page_views).to eq              "1,234" }
  specify { expect(subject.response_values).to start_with %w(Yes Yes Yes) }
  specify { expect(subject.primary_organisation).to eq    "HMRC" }
  specify { expect(subject.other_organisations).to eq     "" }
  specify { expect(subject.content_type).to eq            "Travel Advice" }
  specify { expect(subject.last_major_update).to eq       "15/02/17" }
  specify { expect(subject.whitehall_url).to eq           expected_whitehall_url }

  context "when the content item hasn't been audited" do
    before { audit.destroy }

    specify { expect(subject.is_work_needed).to be_nil }
    specify { expect(subject.response_values).to eq [nil] * 10 }
  end

  context "when the content item has many organisations" do
    before do
      aaib = create(:content_item, title: "AAIB")
      maib = create(:content_item, title: "MAIB")

      create(:link, source: content_item, target: aaib, link_type: "organisations")
      create(:link, source: content_item, target: hmrc, link_type: "organisations")
      create(:link, source: content_item, target: maib, link_type: "organisations")
    end

    specify { expect(subject.primary_organisation).to eq "HMRC" }
    specify { expect(subject.other_organisations).to eq  "AAIB, MAIB" }
  end
end

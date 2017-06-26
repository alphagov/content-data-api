RSpec.describe Report do
  let(:request) { double(:request, url: "http://example.com") }

  before do
    FactoryGirl.create(:content_item, title: "Example")
  end

  after do
    ActiveRecord.enable
  end

  subject! { described_class.new(ContentItem.all, request) }

  let(:csv) { subject.generate }
  let(:lines) { csv.split("\n") }
  let(:data) { lines.map { |l| l.split(",") } }

  it "outputs a header row" do
    expect(data.first).to start_with("Report URL", "Report timestamp")
  end

  it "outputs a report metadata row" do
    Timecop.freeze(2017, 1, 30) do
      expect(data.second).to eq %w(http://example.com 30/01/17)
    end
  end

  it "outputs a row for each content item" do
    expect(data.third).to start_with("", "", "Example")
  end

  it "doesn't execute N+1 queries" do
    ActiveRecord.disable

    expect { subject.generate }.not_to raise_error,
      "Should not have tried to execute a query after initializing Report"
  end

  describe Report::Row do
    let(:questions) { Question.limit(3) }
    subject { described_class.new(content_item, questions) }

    let!(:content_item) do
      FactoryGirl.create(
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

    let!(:audit) { FactoryGirl.create(:audit, content_item: content_item) }
    let!(:hmrc) { FactoryGirl.create(:content_item, title: "HMRC") }

    before do
      Question.all.each.with_index do |question, i|
        FactoryGirl.create(
          :response,
          audit: audit,
          question: question,
          value: i.even? ? "yes" : "no",
        )
      end

      FactoryGirl.create(
        :link,
        source: content_item,
        target: hmrc,
        link_type: "primary_publishing_organisation",
      )
    end

    let(:expected_whitehall_url) { "#{WHITEHALL}/government/admin/by-content-id/id123" }

    specify { expect(subject.title).to eq                "Title" }
    specify { expect(subject.url).to eq                  "https://gov.uk/example/path" }
    specify { expect(subject.is_work_needed).to eq       "Yes" }
    specify { expect(subject.page_views).to eq           "1,234" }
    specify { expect(subject.responses).to eq            %w(Yes No Yes) }
    specify { expect(subject.primary_organisation).to eq "HMRC" }
    specify { expect(subject.other_organisations).to eq  "" }
    specify { expect(subject.content_type).to eq         "Travel Advice" }
    specify { expect(subject.last_major_update).to eq    "15/02/17" }
    specify { expect(subject.whitehall_url).to eq        expected_whitehall_url }

    context "when the content item hasn't been audited" do
      before { audit.destroy }

      specify { expect(subject.is_work_needed).to be_nil }
      specify { expect(subject.responses).to eq   [nil, nil, nil] }
    end

    context "when the content item has many organisations" do
      before do
        aaib = FactoryGirl.create(:content_item, title: "AAIB")
        maib = FactoryGirl.create(:content_item, title: "MAIB")

        FactoryGirl.create(:link, source: content_item, target: aaib, link_type: "organisations")
        FactoryGirl.create(:link, source: content_item, target: hmrc, link_type: "organisations")
        FactoryGirl.create(:link, source: content_item, target: maib, link_type: "organisations")
      end

      specify { expect(subject.primary_organisation).to eq "HMRC" }
      specify { expect(subject.other_organisations).to eq  "AAIB, MAIB" }
    end
  end
end

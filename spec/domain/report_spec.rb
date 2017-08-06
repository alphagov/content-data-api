module Audits
  RSpec.describe Report do
    before do
      create(:content_item, title: "Example")
    end

    after do
      ActiveRecord.enable
    end

    subject! { described_class.new(Filter.new, "http://example.com") }

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
  end
end

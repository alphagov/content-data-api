module Audits
  RSpec.describe Report do
    before do
      create(:content_item, title: 'Example')
    end

    let(:filter) { build(:filter) }
    let(:url) { 'http://example.com' }

    it 'outputs a header row' do
      csv = Report.generate(filter, url)

      expect(csv.lines.first).to start_with('Report URL,Report timestamp')
    end

    it 'outputs whether the item has been audited or not' do
      csv = Report.generate(filter, url)
      header = csv.lines.first
      first_row = csv.lines.third

      expect(header).to match(/Audited/)
      expect(first_row).to match(/Not audited/)
    end

    it 'outputs a report metadata row' do
      Timecop.freeze(2017, 1, 30) do
        csv = Report.generate(filter, url)

        expect(csv.lines.second).to eq "http://example.com,30/01/17\n"
      end
    end

    it 'outputs a row for each content item' do
      csv = Report.generate(filter, url)

      expect(csv.lines.third).to start_with(',,Example')
    end

    it "doesn't execute N+1 queries" do
      ActiveRecord.disable

      expect { Report.generate(filter, url) }.not_to raise_error,
        'Should not have tried to execute a query after initializing Report'
    end

    it 'returns all items regardless of the audit status' do
      create(:passing_audit)
      create(:failing_audit)

      expect(Report.generate(filter, url).lines.length).to eq(5)
    end

    it 'returns items filtered by audit status' do
      create(:passing_audit)

      filter.audit_status = Audit::AUDITED
      expect(Report.generate(filter, url).lines.length).to eq(3)

      filter.audit_status = Audit::NON_AUDITED
      expect(Report.generate(filter, url).lines.length).to eq(3)

      filter.audit_status = Audit::ALL
      expect(Report.generate(filter, url).lines.length).to eq(4)
    end

    after do
      ActiveRecord.enable
    end
  end
end

module Audits
  RSpec.describe Report do
    let(:filter) { build(:filter) }
    let(:url) { 'http://example.com' }

    describe 'Layout' do
      it 'outputs a header row' do
        csv = Report.generate(filter, url)

        expect(csv.lines.first).to start_with('Report URL,Report timestamp')
      end

      it 'outputs a report metadata row' do
        Timecop.freeze(2017, 1, 30) do
          csv = Report.generate(filter, url)

          expect(csv.lines.second).to eq "http://example.com,30/01/17\n"
        end
      end
    end

    describe 'Row content' do
      before do
        create(:content_item, title: 'Example')
      end

      let(:csv) { Report.generate(filter, url) }
      let(:first_row) { csv.lines.third }

      it 'outputs whether the item has been audited or not' do
        header = csv.lines.first

        expect(header).to match(/Audited/)
        expect(first_row).to match(/Not audited/)
      end

      it 'outputs a row for each content item' do
        expect(first_row).to start_with(',,Example')
      end

      it "doesn't execute N+1 queries" do
        ActiveRecord.disable

        expect { Report.generate(filter, url) }.not_to raise_error,
          'Should not have tried to execute a query after initializing Report'
      end
    end


    describe 'Filter content' do
      it 'returns items filtered by audit status' do
        create(:content_item)
        create(:passing_audit)

        header_rows = 2

        filter.audit_status = Audit::AUDITED
        expect(Report.generate(filter, url).lines.length).to eq(header_rows + 1)

        filter.audit_status = Audit::NON_AUDITED
        expect(Report.generate(filter, url).lines.length).to eq(header_rows + 1)

        filter.audit_status = Audit::ALL
        expect(Report.generate(filter, url).lines.length).to eq(header_rows + 2)
      end
    end

    after do
      ActiveRecord.enable
    end
  end
end

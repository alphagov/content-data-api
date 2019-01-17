RSpec.describe Finders::AllOrganisations do
  subject { described_class }

  describe '.find_all' do
    context 'sorting' do
      before do
        create(:edition, document_type: 'organisation', title: 'Organisation C')
        create(:edition, document_type: 'organisation', title: 'Organisation A')
        create(:edition, document_type: 'organisation', title: 'Organisation B')
      end

      it 'returns a list of organisations' do
        organisations = subject.run
        expect(organisations).to all be_a(Organisation)
      end

      it 'returns a list sorted by title' do
        organisations = subject.run

        expect(organisations).to be_sorted_by(&:name)
      end
    end

    context 'locales' do
      before do
        create(:edition, document_type: 'organisation', content_id: '1', title: 'English Name', locale: 'en')
        create(:edition, document_type: 'organisation', content_id: '1', title: 'Enw Cymraeg', locale: 'cy')
      end

      it 'returns only english locales by default' do
        organisations = subject.run

        expect(organisations).to match_array([have_attributes(name: 'English Name')])
      end

      it 'returns welsh locales when specified' do
        organisations = subject.run(locale: 'cy')

        expect(organisations).to match_array([have_attributes(name: 'Enw Cymraeg')])
      end
    end

    context 'when no data' do
      it 'returns an empty array' do
        expect(described_class.run).to eq([])
      end
    end
  end
end

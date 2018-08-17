RSpec.describe Etl::Item::Processor do
  include ItemSetupHelpers
  let(:old_item) do
    create_edition(
      base_path: '/base-path',
      date: Date.today,
      item: {
        document_text: 'existing content',
        latest: false
      },
      edition: {
        word_count: 2,
      }
).dimensions_item
  end
  subject { described_class.new(old_item: old_item, new_item: new_item, date: Date.today) }

  before do
    allow(Etl::Item::Metadata::NumberOfWordFiles).to receive(:parse).and_return(1)
    allow(Etl::Item::Metadata::NumberOfPdfs).to receive(:parse).and_return(2)
    subject.run
  end

  context 'when the content has changed' do
    let(:new_item) do
      create(:dimensions_item, base_path: '/base-path', document_text: 'fresh new content')
    end

    it 'creates a new edition' do
      expect(new_item.reload.facts_edition).to be_persisted
    end

    it 'populates word count for the new edition' do
      expect(new_item.reload.facts_edition.word_count).to eq 3
    end
  end

  context 'when the content has not changed' do
    let(:new_item) do
      build(:dimensions_item, base_path: '/base-path', document_text: 'existing content')
    end

    it 'clones the existing edition' do
      updated_item = new_item.reload
      expect(updated_item.facts_edition).to be_persisted
      expect(updated_item.facts_edition).to have_attributes(
        word_count: 2
      )
    end
  end
end

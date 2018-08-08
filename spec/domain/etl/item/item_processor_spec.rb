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
        contractions_count: 2,
        equality_count: 3,
        indefinite_article_count: 4,
      }
).dimensions_item
  end
  subject { described_class.new(old_item: old_item, new_item: new_item, date: Date.today) }

  before do
    allow(Etl::Jobs::QualityMetricsJob).to receive(:perform_async)
    allow(Etl::Item::Metadata::NumberOfWordFiles).to receive(:parse).and_return(1)
    allow(Etl::Item::Metadata::NumberOfPdfs).to receive(:parse).and_return(2)
    subject.run
  end

  context 'when the content has changed' do
    let(:new_item) do
      create(:dimensions_item, base_path: '/base-path', document_text: 'new content')
    end

    it 'creates a new edition' do
      expect(new_item.reload.facts_edition).to be_persisted
    end

    it 'fires a sidekiq job to populate quality metrics for the new edition' do
      expect(Etl::Jobs::QualityMetricsJob).to have_received(:perform_async).with(new_item.id)
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
        contractions_count: 2,
        equality_count: 3,
        indefinite_article_count: 4,
      )
    end

    it 'does not fire a sidekiq job to populate quality metrics' do
      expect(Etl::Jobs::QualityMetricsJob).not_to have_received(:perform_async)
    end
  end
end

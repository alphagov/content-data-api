RSpec.describe Facts::Edition do
  let(:dimensions_item) { create :dimensions_item }
  let(:dimensions_date) { create :dimensions_date }
  let(:new_item) { create :dimensions_item }
  let(:new_date) { create :dimensions_date }
  let(:quality_metrics) do
    {
      pdf_count: 1,
      doc_count: 1,
      readability: 97,
      chars: 21,
      sentences: 1,
      words: 4,
    }
  end

  let(:existing_edition) do
    create :facts_edition,
      { dimensions_item: dimensions_item,
        dimensions_date: dimensions_date }.merge(quality_metrics)
  end

  it 'clones correctly with the quality metrics populated' do
    cloned_edition = existing_edition.clone_for!(new_item, new_date)
    expect(cloned_edition).to have_attributes(
      quality_metrics.merge(
        dimensions_item: new_item,
        dimensions_date: new_date
      )
    )
    expect(cloned_edition).to be_persisted
  end
end

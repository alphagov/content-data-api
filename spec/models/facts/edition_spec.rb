RSpec.describe Facts::Edition do
  let(:edition) { create :edition, facts: quality_metrics }
  let(:new_item) { create :edition }
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

  it 'clones correctly with the quality metrics populated' do
    existing_facts_edition = edition.reload.facts_edition
    cloned_edition = existing_facts_edition.clone_for!(new_item, new_date)
    expect(cloned_edition).to have_attributes(
      quality_metrics.merge(
        dimensions_item: new_item,
        dimensions_date: new_date
      )
    )
    expect(cloned_edition).to be_persisted
  end
end

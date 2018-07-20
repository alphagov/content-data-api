RSpec.describe Facts::Edition do
  let(:dimensions_item) { create :dimensions_item }
  let(:dimensions_date) { create :dimensions_date }
  let(:new_item) { create :dimensions_item }
  let(:new_date) { create :dimensions_date }
  let(:quality_metrics) do
    {
      number_of_pdfs: 1,
      number_of_word_files: 1,
      readability_score: 97,
      string_length: 21,
      sentence_count: 1,
      word_count: 4,
      contractions_count: 2,
      equality_count: 3,
      indefinite_article_count: 4,
      passive_count: 5,
      profanities_count: 6,
      redundant_acronyms_count: 7,
      repeated_words_count: 8,
      simplify_count: 9,
      spell_count: 10,
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

RSpec.describe Items::Importers::QualityMetrics do
  let(:dimensions_item) { create :dimensions_item }
  subject { Items::Importers::QualityMetrics.new(dimensions_item.id) }

  context 'import quality metrics' do
    before do
      allow_any_instance_of(Dimensions::Item).to receive(:get_content).and_return('the-entire-body')
      allow(subject.content_quality_service).to receive(:run).with('the-entire-body').and_return(
        readability_score: 1,
        contractions_count: 2,
        equality_count: 3,
        indefinite_article_count: 4,
        passive_count: 5,
        profanities_count: 6,
        redundant_acronyms_count: 7,
        repeated_words_count: 8,
        simplify_count: 9,
        spell_count: 10
      )
    end

    it 'updates the metadata fields for dimensions item' do
      subject.run
      expect(dimensions_item.reload).to have_attributes(
        spell_count: 10,
        readability_score: 1,
        contractions_count: 2,
        equality_count: 3,
        passive_count: 5,
        indefinite_article_count: 4,
        profanities_count: 6,
        redundant_acronyms_count: 7,
        repeated_words_count: 8,
        simplify_count: 9,
      )
    end

    it 'does not update fields if InvalidSchemaError is raised' do
      allow_any_instance_of(Dimensions::Item).to receive(:get_content).and_raise(InvalidSchemaError)
      subject.run
      expect(dimensions_item.reload).to have_attributes(
        spell_count: nil,
        readability_score: nil,
        contractions_count: nil,
        equality_count: nil,
        passive_count: nil,
        indefinite_article_count: nil,
        profanities_count: nil,
        redundant_acronyms_count: nil,
        repeated_words_count: nil,
        simplify_count: nil
      )
    end

    it 'creates a fact record' do
      subject.run

      fact = dimensions_item.reload.facts_edition

      expect(fact).not_to be_nil

      expect(fact).to have_attributes(
        spell_count: 10,
        readability_score: 1,
        contractions_count: 2,
        equality_count: 3,
        passive_count: 5,
        indefinite_article_count: 4,
        profanities_count: 6,
        redundant_acronyms_count: 7,
        repeated_words_count: 8,
        simplify_count: 9
      )
    end
  end
end

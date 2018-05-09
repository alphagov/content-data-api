RSpec.feature 'Quality metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:day0) { create :dimensions_date, date: Date.new(2018, 1, 12) }
  let(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }

  context 'Content metrics' do
    metrics = %w(
      contractions_count
      equality_count
      indefinite_article_count
      number_of_pdfs
      number_of_word_files
      passive_count
      profanities_count
      readability_score
      redundant_acronyms_count
      repeated_words_count
      sentence_count
      simplify_count
      spell_count
      string_length
      word_count
    )

    metrics.each do |metric_name|
      scenario "Show Stats for #{metric_name}" do
        item1 = create :dimensions_item
        item2 = create :dimensions_item

        create :metric, dimensions_item: item1, dimensions_date: day0
        create :metric, dimensions_item: item2, dimensions_date: day1

        create :facts_edition, dimensions_item: item1, dimensions_date: day0, metric_name => 10
        create :facts_edition, dimensions_item: item2, dimensions_date: day1, metric_name => 10

        visit '/sandbox'

        fill_in 'From:', with: '2018-01-1'
        fill_in 'To:', with: '2018-01-30'
        check metric_name
        click_button 'Filter'

        expect(page).to have_selector(".#{metric_name} .total", text: 'Total = 20')
        expect(page).to have_selector(".#{metric_name} .average", text: 'Avg = 10.00')
      end
    end
  end
end

RSpec.feature 'Quality metrics', type: :feature do
  include MetricsHelpers
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

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
        create_metric base_path: '/path/1', date: '2018-01-12', edition: { metric_name => 10 }
        create_metric base_path: '/path/2', date: '2018-01-13', edition: { metric_name => 10 }

        visit '/sandbox'

        fill_in 'From:', with: '2018-01-1'
        fill_in 'To:', with: '2018-01-30'
        select metric_name, from: 'metric1'
        click_button 'Filter'

        expect(page).to have_selector(".#{metric_name} .total", text: 'Total = 20')
        expect(page).to have_selector(".#{metric_name} .average", text: 'Avg = 10.00')
      end
    end
  end
end

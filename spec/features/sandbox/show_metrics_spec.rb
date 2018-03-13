RSpec.feature 'Show aggregated metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:day0) { create :dimensions_date, date: Date.new(2018, 1, 12) }
  let(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }

  let(:item1) { create :dimensions_item, content_id: 'id1' }
  let(:item2) { create :dimensions_item, content_id: 'id2' }

  let(:metric1) { create :metric, dimensions_item: item1, dimensions_date: day0 }
  let(:metric2) { create :metric, dimensions_item: item1, dimensions_date: day1 }
  let(:metric3) { create :metric, dimensions_item: item1, dimensions_date: day2 }
  let(:metric4) { create :metric, dimensions_item: item2, dimensions_date: day1 }
  let(:metric5) { create :metric, dimensions_item: item2, dimensions_date: day2 }

  scenario 'Show aggregated metrics' do
    metric1.update pageviews: 10, unique_pageviews: 10, number_of_issues: 2
    metric2.update pageviews: 10, unique_pageviews: 10, number_of_issues: 4
    metric3.update pageviews: 20, unique_pageviews: 20, number_of_issues: 6
    metric4.update pageviews: 20, unique_pageviews: 20, number_of_issues: 8
    metric5.update pageviews: 30, unique_pageviews: 30, number_of_issues: 10

    item1.update number_of_pdfs: 2, number_of_word_files: 1, spell_count: 2, readability_score: 1
    item2.update number_of_pdfs: 4, number_of_word_files: 2, spell_count: 6, readability_score: 5

    visit '/sandbox'

    fill_in 'From:', with: '2018-01-13'
    fill_in 'To:', with: '2018-01-15'
    click_button 'Filter'

    expect(page).to have_selector('.total_items', text: '2 Content Items')
    expect(page).to have_selector('.pageviews', text: '80 Total pageviews')
    expect(page).to have_selector('.unique_pageviews', text: '20.00 Unique pageviews (avg)')
    expect(page).to have_selector('.feedex_issues', text: '28 Feedex issues')
    expect(page).to have_selector('.number_of_pdfs', text: '3.00 PDFs (avg)')
    expect(page).to have_selector('.number_of_word_files', text: '1.50 Word (avg)')
    expect(page).to have_selector('.spell_count', text: '16 Spelling errors')
    expect(page).to have_selector('.readability_score', text: '3.0 Readability score (avg)')
  end

  scenario 'Summary panel when no data' do
    visit '/sandbox'

    fill_in 'From:', with: '2018-01-13'
    fill_in 'To:', with: '2018-01-15'
    click_button 'Filter'

    expect(page).to have_selector('.total_items', text: '0 Content Items')
    expect(page).to have_selector('.pageviews', text: '0 Total pageviews')
    expect(page).to have_selector('.unique_pageviews', text: '0 Unique pageviews (avg)')
    expect(page).to have_selector('.feedex_issues', text: '0 Feedex issues')
    expect(page).to have_selector('.number_of_pdfs', text: '0 PDFs (avg)')
    expect(page).to have_selector('.number_of_word_files', text: '0 Word (avg)')
  end

  scenario 'Download metrics as csv' do
    item1.update(
      title: 'Really interesting',
      description: 'desc',
      content_id: 'cont-id',
      base_path: '/really-interesting'
    )
    metric1.update pageviews: 10
    metric2.update pageviews: 10
    metric3.update pageviews: 5
    visit '/sandbox'
    fill_in 'From:', with: '2018-01-12'
    fill_in 'To:', with: '2018-01-13'

    click_button 'Filter'

    click_on 'Export to CSV'

    expect(page.response_headers['Content-Type']).to eq "text/csv"
    expect(page.response_headers['Content-disposition']).to eq 'attachment; filename="metrics.csv"'
    expect(page.body).to include('2018-01-12,cont-id,/really-interesting,Really interesting,desc')
    expect(page.body).to include('2018-01-13,cont-id,/really-interesting,Really interesting,desc,')
    expect(page.body).not_to include('2018-01-14')
  end

  describe 'Charts' do
    scenario 'Show charts' do
      visit '/sandbox'

      fill_in 'From:', with: '2018-01-13'
      fill_in 'To:', with: '2018-01-15'
      check 'total_items'

      click_button 'Filter'

      expect(page).to have_selector('.trends .total_items', text: 'Number of Content Items')
    end
  end

  describe 'Filtering' do
    scenario 'by base_path' do
      item1.update base_path: '/path'
      item2.update base_path: '/path2'

      create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
      create :metric, dimensions_item: item1, dimensions_date: day2, pageviews: 20
      create :metric, dimensions_item: item2, dimensions_date: day2, pageviews: 30

      visit '/sandbox'

      fill_in 'Base path:', with: '/path'
      click_button 'Filter'

      expect(page).to have_selector('.pageviews', text: '30 Total pageviews')
    end

    scenario 'by organisation' do
      item1.update primary_organisation_content_id: 'org-1'
      item2.update primary_organisation_content_id: 'org-2'
      create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
      create :metric, dimensions_item: item2, dimensions_date: day1, pageviews: 30

      visit '/sandbox'

      fill_in 'Organisation ID:', with: 'org-1'
      click_button 'Filter'

      expect(page).to have_selector('.pageviews', text: '10 Total pageviews')
    end
  end
end

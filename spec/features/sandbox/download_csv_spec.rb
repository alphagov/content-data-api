RSpec.feature 'Show aggregated metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:day0) { create :dimensions_date, date: Date.new(2018, 1, 12) }

  scenario 'Download metrics as csv' do
    item = create :dimensions_item
    metric = create :metric, dimensions_item: item, dimensions_date: day0

    item.content_id = 'content-id'
    item.base_path = '/base-path'
    item.locale = 'en'
    item.title = 'This is the title'
    item.description = 'This is the description'
    item.document_type = 'Guide'
    item.content_purpose_document_supertype = 'Super Guide'
    item.content_purpose_supergroup = 'Guide'
    item.content_purpose_subgroup = 'guidance'
    item.first_published_at = Time.new(2018, 2, 3)
    item.public_updated_at = Time.new(2018, 2, 31)
    item.status = 'live'
    item.primary_organisation_title = 'HMRC'
    item.primary_organisation_content_id = 'the-organisation-id'
    item.save!

    edition = create :facts_edition, dimensions_item: item, dimensions_date: day0
    edition.readability_score = 9
    edition.spell_count = 10
    edition.word_count = 14
    edition.passive_count = 15
    edition.simplify_count = 16
    edition.string_length = 17
    edition.sentence_count = 18
    edition.number_of_pdfs = 22
    edition.number_of_word_files = 23
    edition.save!

    metric.is_this_useful_yes = 11
    metric.is_this_useful_no = 12
    metric.number_of_internal_searches = 13
    metric.pageviews = 19
    metric.unique_pageviews = 20
    metric.feedex_comments = 21
    metric.entrances = 30
    metric.exits = 31
    metric.bounce_rate = 32
    metric.avg_time_on_page = 33
    metric.save!

    visit '/sandbox'
    fill_in 'From:', with: '2018-01-12'
    fill_in 'To:', with: '2018-01-13'

    click_button 'Filter'

    click_on 'Export to CSV'
    expect(page.response_headers['Content-Type']).to eq "text/csv"
    expect(page.response_headers['Content-disposition']).to eq 'attachment; filename="download.csv"'

    header = 'date,content_id,base_path,locale,title,description,document_type,content_purpose_document_supertype,content_purpose_supergroup,content_purpose_subgroup,first_published_at,public_updated_at,status,pageviews,primary_organisation_title,primary_organisation_content_id,unique_pageviews,feedex_comments,number_of_pdfs,number_of_word_files,readability_score,spell_count,is_this_useful_yes,is_this_useful_no,number_of_internal_searches,word_count,passive_count,simplify_count,string_length,sentence_count,entrances,exits,bounce_rate,avg_time_on_page'
    expect(page.body).to include(header)

    row = "2018-01-12,content-id,/base-path,en,This is the title,This is the description,Guide,Super Guide,Guide,guidance,2018-02-03 00:00:00 UTC,2018-03-03 00:00:00 UTC,live,19,HMRC,the-organisation-id,20,21,22,23,9,10,11,12,13,14,15,16,17,18,30,31,32,33"
    expect(page.body).to include(row)
  end
end

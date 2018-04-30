RSpec.describe 'Master process spec' do
  let(:today) { Date.new(2018, 2, 21) }

  around do |example|
    Timecop.freeze(today) do
      example.run
    end
  end

  let(:content_id) { 'id1' }
  let(:base_path) { '/the-base-path' }
  let(:old_base_path) { '/old/base/path' }
  let(:locale) { 'en' }
  let(:item_content) { 'This is the content.' }


  let!(:an_item) { create :dimensions_item, content_id: 'a-content-id', locale: locale }
  let!(:outdated_item) do
    create :dimensions_item, content_id: content_id,
      base_path: old_base_path, locale: locale, latest: false
  end
  let!(:item) do
    create :dimensions_item,
      content_id: content_id, base_path: base_path,
      locale: locale
  end

  it 'orchestrates all ETL processes' do
    stub_google_analytics_response
    stub_google_analytics_user_feedback_response
    stub_google_analytics_internal_search_response
    stub_feedex_response

    Master::MasterProcessor.process

    validate_facts_metrics!
    validate_google_analytics!
    validate_feedex!
  end

  def latest_version
    Dimensions::Item.find_by(latest: true, content_id: 'id1')
  end

  def latest_metric
    Facts::Metric
      .joins(:dimensions_item)
      .where(dimensions_items: { latest: true, content_id: 'id1' })
      .first
  end

  def validate_facts_metrics!
    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.pluck(:dimensions_item_id)).to match_array([an_item.id, latest_version.id])
    expect(Facts::Metric.pluck(:dimensions_date_id).uniq).to match_array(Date.new(2018, 2, 20))
  end

  def validate_google_analytics!
    expect(latest_metric).to have_attributes(
      pageviews: 11,
      unique_pageviews: 12,
    )
  end

  def validate_feedex!
    expect(latest_metric).to have_attributes(feedex_comments: 21)
  end

  def validate_quality_metrics
    expect(latest_metric).to have_attributes(
      repeated_words_count: 8,
      passive_count: 6,
    )
  end

  def stub_google_analytics_response
    allow(GA::ViewsService).to receive(:find_in_batches).and_yield(
      [
        {
          'page_path' => base_path,
          'pageviews' => 11,
          'unique_pageviews' => 12,
          'date' => '2018-02-20',
          'process_name' => 'views',
        },
        {
          'page_path' => '/path2',
          'pageviews' => 2,
          'unique_pageviews' => 2,
          'date' => '2018-02-20',
          'process_name' => 'views',
        },
      ]
    )
  end

  def stub_google_analytics_user_feedback_response
    allow(GA::UserFeedbackService).to receive(:find_in_batches).and_yield(
      [
        {
          'page_path' => base_path,
          'is_this_useful_no' => 1,
          'is_this_useful_yes' => 12,
          'date' => '2018-02-20',
          'process_name' => 'user_feedback',
        },
        {
          'page_path' => base_path,
          'is_this_useful_no' => 122,
          'is_this_useful_yes' => 1,
          'date' => '2018-02-20',
          'process_name' => 'user_feedback',
        },
      ]
    )
  end

  def stub_google_analytics_internal_search_response
    allow(GA::InternalSearchService).to receive(:find_in_batches).and_yield(
      [
        {
          'page_path' => '/path1',
          'number_of_internal_searches' => 1,
          'date' => '2018-02-20',
          'process_name' => 'number_of_internal_searches'
        },
        {
          'page_path' => '/path2',
          'number_of_internal_searches' => 2,
          'date' => '2018-02-20',
          'process_name' => 'number_of_internal_searches'
        },
      ]
    )
  end

  def stub_feedex_response
    response = {
      'results': [{
        'date': '2018-02-20',
        'path': base_path,
        'count': 21
      }, {
        'date': '2018-02-20',
        'path': '/path2',
        'count': 1
      }, {
        'date': '2018-02-20',
        'path': '/path3',
        'count': 1
      }],
      'total_count': 3,
      'current_page': 1,
      'pages': 1,
      'page_size': 3
    }.to_json

    stub_request(:get, 'http://support-api.dev.gov.uk/feedback-by-day/2018-02-20?page=1&per_page=10000').
      to_return(status: 200, body: response, headers: {})
  end
end

RSpec.describe 'Master process spec' do
  let(:today) { Date.new(2018, 2, 21) }
  around do |example|
    Timecop.freeze(today) do
      example.run
    end
  end

  let!(:an_item) { create :dimensions_item }
  let!(:outdated_item) { create :dimensions_item, content_id: 'id1', base_path: '/path-1', latest: false }
  let!(:item) { create :dimensions_item, content_id: 'id1', base_path: '/path-1', latest: true }

  it 'orchestrates all ETL processes' do
    stub_google_analytics_response
    stub_google_analytics_user_feedback_response
    stub_google_analytics_internal_search_response
    stub_feedex_response
    stub_monitoring

    Etl::Master::MasterProcessor.process

    validate_facts_metrics!
    validate_google_analytics!
    validate_feedex!
    validate_monitoring!
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

  def validate_satisfaction_score!
    expect(latest_metric).to have_attributes(
      is_this_useful_yes: 1,
      is_this_useful_no: 1,
      satisfaction_score: 0.5
    )
  end

  def validate_feedex!
    expect(latest_metric).to have_attributes(feedex_comments: 21)
  end

  def validate_monitoring!
    expect(GovukStatsd).to have_received(:count).at_least(1).times
  end

  def stub_google_analytics_response
    allow(Etl::GA::ViewsAndNavigationService).to receive(:find_in_batches).and_yield(
      [
        {
          'page_path' => '/path-1',
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
    allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(
      [
        {
          'page_path' => '/path-1',
          'is_this_useful_no' => 1,
          'is_this_useful_yes' => 12,
          'date' => '2018-02-20',
          'process_name' => 'user_feedback',
        },
        {
          'page_path' => '/path2',
          'is_this_useful_no' => 122,
          'is_this_useful_yes' => 1,
          'date' => '2018-02-20',
          'process_name' => 'user_feedback',
        },
      ]
    )
  end

  def stub_google_analytics_internal_search_response
    allow(Etl::GA::InternalSearchService).to receive(:find_in_batches).and_yield(
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

  def stub_monitoring
    allow(GovukStatsd).to receive(:count)
  end

  def stub_feedex_response
    response = {
      'results': [{
        'date': '2018-02-20',
        'path': '/path-1',
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

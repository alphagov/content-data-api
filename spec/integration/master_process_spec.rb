require 'sidekiq/testing'
require 'gds_api/test_helpers/content_store'

RSpec.describe 'Master process spec' do
  include GdsApi::TestHelpers::ContentStore

  let(:today) { Date.new(2018, 2, 21) }

  around do |example|
    Sidekiq::Testing.inline! do
      Timecop.freeze(today) do
        example.run
      end
    end
  end

  let(:content_id) { 'id1' }
  let(:base_path) { '/the-base-path' }
  let(:locale) { 'en' }
  let(:item_content) { 'This is the content.' }


  let!(:an_item) { create :dimensions_item, content_id: 'a-content-id', locale: locale }
  let!(:outdated_item) do
    create :outdated_item, content_id: content_id,
      base_path: '/old/base/path', locale: locale, latest: false
  end
  let!(:item) do
    create :outdated_item,
      content_id: content_id, base_path: base_path,
      locale: locale, outdated_at: 2.days.ago
  end

  it 'orchestrates all ETL processes' do
    stub_google_analytics_response
    stub_feedex_response
    stub_content_store_response
    stub_quality_metrics_response

    Master::Master.process

    validate_facts_metrics!
    validate_outdated_items!
    validate_metadata!
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

  def validate_outdated_items!
    expect(Dimensions::Item.count).to eq(4)

    expect(Dimensions::Item.where(latest: true, content_id: 'id1', base_path: base_path).count).to eq(1)
  end

  def validate_metadata!
    expect(latest_version).to have_attributes(
      title: 'title1',
      document_type: 'document_type1',
    )
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

  def stub_content_store_response
    response = content_item_for_base_path(base_path)
    response.merge!(
      'content_id' => content_id,
      'base_path' => base_path,
      'schema_name' => 'news_article',
      'title' => 'title1',
      'document_type' => 'document_type1',
      'details' => {
        'body' => item_content,
      }
    )
    content_store_has_item(base_path, response, {})
  end

  def stub_quality_metrics_response
    quality_metrics_response = {
      passive: { 'count' => 5 },
      repeated_words: { 'count' => 8 },
    }
    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics').
      with(
        body: { content: item_content }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      .to_return(
        status: 200,
        body: quality_metrics_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_google_analytics_response
    allow_any_instance_of(GoogleAnalyticsService).to receive(:find_in_batches).and_yield(
      [
        {
          'page_path' => base_path,
          'pageviews' => 11,
          'unique_pageviews' => 12,
          'date' => '2018-02-20',
        },
        {
          'page_path' => '/path2',
          'pageviews' => 2,
          'unique_pageviews' => 2,
          'date' => '2018-02-20',
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

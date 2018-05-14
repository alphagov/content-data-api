require 'sidekiq/testing'
require 'gds_api/test_helpers/content_store'

RSpec.describe 'PublishingAPI events' do
  include GdsApi::TestHelpers::ContentStore

  around do |example|
    Sidekiq::Testing.inline! do
      Timecop.freeze(today) do
        example.run
      end
    end
  end

  before do
    stub_google_analytics_response
    stub_google_analytics_user_feedback_response
    stub_google_analytics_internal_search_response
    stub_feedex_response
    stub_quality_metrics_response
    stub_content_store_response(title: 'title1', base_path: base_path)
  end

  let(:content_id) { 'id1' }
  let(:base_path) { '/the-base-path' }
  let(:locale) { 'en' }
  let(:today) { Date.new(2018, 2, 21) }
  let(:message) { build_publishing_api_message(base_path, content_id, locale, payload_version: 1) }
  let(:another_message) { build_publishing_api_message(base_path, content_id, locale, payload_version: 2) }

  context 'having received a new version yesterday' do
    before do
      Timecop.freeze(Date.yesterday) { PublishingApiConsumer.new.process(message) }
    end

    it 'the master process will still try to populate it today' do
      Master::MasterProcessor.process date: today

      facts = Facts::Metric.joins(:dimensions_item).where(dimensions_items: { content_id: content_id })

      expect(facts.count).to eq(1)
    end
  end

  context 'having processed two versions yesterday' do
    before do
      Timecop.freeze(Date.yesterday) do
        PublishingApiConsumer.new.process(message)
        PublishingApiConsumer.new.process(another_message)
      end
    end

    it 'populates daily metrics for the latest content item only' do
      Master::MasterProcessor.process date: today

      latest_item_facts = Facts::Metric.joins(:dimensions_item).where(
        dimensions_items: { latest: true, content_id: content_id, base_path: base_path }
      ).count

      not_latest_item_facts = Facts::Metric.joins(:dimensions_item).where(
        dimensions_items: { latest: false, content_id: content_id, base_path: base_path }
      ).count

      expect(latest_item_facts).to eq(1)
      expect(not_latest_item_facts).to eq(0)
    end
  end

  def build_publishing_api_message(base_path, content_id, locale, payload_version: 1)
    message = double('message',
      payload: {
        'base_path' => base_path,
        'content_id' => content_id,
        'locale' => locale,
        'payload_version' => payload_version
      },
      delivery_info: double('del_info', routing_key: 'news_story.major'))
    allow(message).to receive(:ack)

    message
  end

  def stub_content_store_response(title:, base_path:)
    response = content_item_for_base_path(base_path)
    response.merge!(
      'content_id' => content_id,
      'schema_name' => 'news_article',
      'base_path' => base_path,
      'title' => title,
      'details' => { 'body' => 'content' }
    )
    content_store_has_item(base_path, response, {})
  end

  def stub_quality_metrics_response
    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics')
      .to_return(status: 200, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def stub_google_analytics_response
    allow(GA::ViewsAndNavigationService).to receive(:find_in_batches).and_yield([])
  end

  def stub_google_analytics_user_feedback_response
    allow(GA::UserFeedbackService).to receive(:find_in_batches).and_yield([])
  end

  def stub_google_analytics_internal_search_response
    allow(GA::InternalSearchService).to receive(:find_in_batches).and_yield([])
  end

  def stub_feedex_response
    response = { 'results': [], 'total_count': 0, 'current_page': 1, 'pages': 1, 'page_size': 1 }.to_json
    stub_request(:get, "http://support-api.dev.gov.uk/feedback-by-day/2018-02-21?page=1&per_page=10000").
      to_return(status: 200, body: response, headers: {})
    stub_request(:get, "http://support-api.dev.gov.uk/feedback-by-day/2018-02-22?page=1&per_page=10000").
      to_return(status: 200, body: response, headers: {})
  end
end

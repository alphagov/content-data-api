require 'sidekiq/testing'
require 'gds_api/test_helpers/content_store'

RSpec.describe 'new content from the publishing feed' do
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
    stub_feedex_response
    stub_quality_metrics_response
    stub_content_store_response(title: 'title1', base_path: base_path)
  end

  let(:content_id) { 'id1' }
  let(:base_path) { '/the-base-path' }
  let(:locale) { 'en' }
  let(:today) { Date.new(2018, 2, 21) }
  let(:message) { build_publishing_api_message(base_path, content_id, locale) }

  context 'with a new item event' do
    it 'the master process creates a new item' do
      Timecop.freeze(Date.yesterday) { PublishingApiConsumer.new.process(message) }

      ETL::Master.process date: today

      expect(latest_version).to have_attributes(
        content_id: content_id,
        base_path: base_path,
        locale: locale
      )
      validate_outdated_items!(total: 2, base_path: base_path)
    end
  end

  describe 'update item event' do
    before do
      Timecop.freeze(Date.yesterday) do
        PublishingApiConsumer.new.process(message)
      end

      ETL::Master.process date: today
    end

    context 'once updated by another publishing event' do
      let(:new_base_path) { '/updated/base/path' }
      let(:updated_content) { 'updated content' }
      let(:new_message) { build_publishing_api_message(new_base_path, content_id, locale) }

      before do
        PublishingApiConsumer.new.process(new_message)
        stub_content_store_response(title: 'updated title', base_path: new_base_path)
      end

      it 'creates a new item with the updated data' do
        ETL::Master.process date: today + 1.day

        expect(latest_version).to have_attributes(
          content_id: content_id,
          base_path: new_base_path,
          locale: locale
        )

        validate_outdated_items!(total: 3, base_path: new_base_path)
      end
    end
  end

  def build_publishing_api_message(base_path, content_id, locale)
    message = double('message',
      payload: {
        'base_path' => base_path,
        'content_id' => content_id,
        'locale' => locale
      },
      delivery_info: double('del_info', routing_key: 'news_story.major'))
    allow(message).to receive(:ack)

    message
  end

  def latest_version
    Dimensions::Item.by_natural_key(content_id: content_id, locale: locale)
  end

  def validate_outdated_items!(total:, base_path:)
    expect(Dimensions::Item.count).to eq(total)
    expect(Dimensions::Item.where(latest: true, content_id: content_id, base_path: base_path).count).to eq(1)
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
    allow_any_instance_of(GoogleAnalyticsService).to receive(:find_in_batches).and_yield([])
  end

  def stub_feedex_response
    response = { 'results': [], 'total_count': 0, 'current_page': 1, 'pages': 1, 'page_size': 1 }.to_json
    stub_request(:get, "http://support-api.dev.gov.uk/feedback-by-day/2018-02-21?page=1&per_page=10000").
      to_return(status: 200, body: response, headers: {})
    stub_request(:get, "http://support-api.dev.gov.uk/feedback-by-day/2018-02-22?page=1&per_page=10000").
      to_return(status: 200, body: response, headers: {})
  end
end

require 'sidekiq/testing'
require 'gds_api/test_helpers/content_store'

RSpec.describe 'new content from the publishing feed' do
  include GdsApi::TestHelpers::ContentStore

  let(:content_id) { 'id1' }
  let(:base_path) { '/the-base-path' }
  let(:locale) { 'en' }
  let(:today) { Date.new(2018, 2, 21) }
  let(:item_content) { 'the content' }

  around do |example|
    Sidekiq::Testing.inline! do
      Timecop.freeze(today) do
        example.run
      end
    end
  end

  let!(:payload) do
    {
      'base_path' => base_path,
      'content_id' => content_id,
      'locale' => locale
    }
  end
  let!(:message) do
    double('message',
      payload: payload,
      delivery_info: double('del_info', routing_key: 'news_story.major'))
  end

  before do
    allow(message).to receive(:ack)
    Timecop.freeze(today - 1.day) do
      PublishingApiConsumer.new.process(message)
    end
    stub_google_analytics_response(
      base_path: base_path,
      date: '2018-02-21',
      request_date: today,
      pageviews: 11,
      unique_pageviews: 5
    )
    stub_feedex_response(base_path: base_path, date: '2018-02-20', request_date: "2018-02-21", comments: 21)
    stub_quality_metrics_response(content: item_content, passive_count: 6, repeated_count: 8)
    stub_content_store_response(title: 'title1', content: item_content, base_path: base_path)

    ETL::Master.process date: today
  end

  context 'after the initial load' do
    it 'creates the latest item with the correct attributes' do
      expect(latest_version).to have_attributes(
        content_id: content_id,
        base_path: base_path,
        locale: locale
      )
      validate_facts_metrics!(count: 1, dates: [Date.new(2018, 2, 21)], ids: [latest_version.id])
      validate_outdated_items!(total: 2, base_path: base_path)
      validate_metadata!(title: 'title1')
      validate_quality_metrics!(passive_count: 6, repeated_count: 8)
      validate_google_analytics!(pageviews: 11, unique_pageviews: 5)
      validate_feedex!(comments: 21)
    end
  end

  context 'once updated by another publishing event' do
    let(:new_base_path) { '/updated/base/path' }
    let(:updated_content) { 'updated content' }
    let(:new_message) do
      double('new_message',
        payload: payload.merge('base_path' => new_base_path),
        delivery_info: message.delivery_info)
    end
    before do
      allow(new_message).to receive(:ack)
      PublishingApiConsumer.new.process(new_message)
      stub_google_analytics_response(
        base_path: new_base_path,
        date: '2018-02-22',
        request_date: today + 1.day,
        pageviews: 25,
        unique_pageviews: 12
      )
      stub_feedex_response(base_path: new_base_path, date: '2018-02-21', request_date: "2018-02-22", comments: 18)
      stub_quality_metrics_response(content: updated_content, passive_count: 10, repeated_count: 5)
      stub_content_store_response(title: 'updated title', content: updated_content, base_path: new_base_path)
    end

    it 'creates a new item with the updated data' do
      original_version_id = latest_version.id
      ETL::Master.process date: today + 1.day

      expect(latest_version).to have_attributes(
        content_id: content_id,
        base_path: new_base_path,
        locale: locale
      )

      validate_facts_metrics!(count: 2,
        dates: [Date.new(2018, 2, 21), Date.new(2018, 2, 22)],
        ids: [original_version_id, latest_version.id])
      validate_outdated_items!(total: 3, base_path: new_base_path)
      validate_metadata!(title: 'updated title')
      validate_quality_metrics!(passive_count: 10, repeated_count: 5)
      validate_google_analytics!(pageviews: 25, unique_pageviews: 12)
      validate_feedex!(comments: 18)
    end
  end

  def latest_version
    Dimensions::Item.by_natural_key(content_id: content_id, locale: locale)
  end

  def latest_metric
    Facts::Metric
      .joins(:dimensions_item)
      .where(dimensions_items: { latest: true, content_id: content_id })
      .first
  end

  def validate_facts_metrics!(count:, dates:, ids:)
    expect(Facts::Metric.count).to eq(count)
    expect(Facts::Metric.pluck(:dimensions_item_id)).to match_array(ids)
    expect(Facts::Metric.pluck(:dimensions_date_id).uniq).to match_array(dates)
  end

  def validate_outdated_items!(total:, base_path:)
    expect(Dimensions::Item.count).to eq(total)
    expect(Dimensions::Item.where(latest: true, content_id: content_id, base_path: base_path).count).to eq(1)
  end

  def validate_metadata!(title:)
    expect(latest_version).to have_attributes(
      title: title,
      document_type: 'document_type1',
    )
  end

  def validate_google_analytics!(pageviews:, unique_pageviews:)
    expect(latest_metric).to have_attributes(
      pageviews: pageviews,
      unique_pageviews: unique_pageviews,
    )
  end

  def validate_feedex!(comments:)
    expect(latest_metric).to have_attributes(feedex_comments: comments)
  end

  def validate_quality_metrics!(passive_count:, repeated_count:)
    expect(latest_version).to have_attributes(
      repeated_words_count: repeated_count,
      passive_count: passive_count,
    )
  end

  def stub_content_store_response(title:, content:, base_path:)
    response = content_item_for_base_path(base_path)
    response.merge!(
      'content_id' => content_id,
      'base_path' => base_path,
      'schema_name' => 'news_article',
      'title' => title,
      'document_type' => 'document_type1',
      'details' => {
        'body' => content,
      }
    )
    content_store_has_item(base_path, response, {})
  end

  def stub_quality_metrics_response(content:, passive_count:, repeated_count:)
    quality_metrics_response = {
      passive: { 'count' => passive_count },
      repeated_words: { 'count' => repeated_count },
    }
    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics').
      with(
        body: { content: content }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      .to_return(
        status: 200,
        body: quality_metrics_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_google_analytics_response(base_path:, date:, request_date:, pageviews:, unique_pageviews:)
    allow_any_instance_of(GoogleAnalyticsService).to receive(:find_in_batches).with(date: request_date).and_yield(
      [
        {
          'page_path' => base_path,
          'pageviews' => pageviews,
          'unique_pageviews' => unique_pageviews,
          'date' => date,
        },
        {
          'page_path' => '/path2',
          'pageviews' => 2,
          'unique_pageviews' => 2,
          'date' => date,
        },
      ]
    )
  end

  def stub_feedex_response(base_path:, date:, comments:, request_date:)
    response = {
      'results': [{
        'date': date,
        'path': base_path,
        'count': comments
      }, {
        'date': date,
        'path': '/path2',
        'count': 1
      }, {
        'date': date,
        'path': '/path3',
        'count': 1
      }],
      'total_count': 3,
      'current_page': 1,
      'pages': 1,
      'page_size': 3
    }.to_json

    stub_request(:get, "http://support-api.dev.gov.uk/feedback-by-day/#{request_date}?page=1&per_page=10000").
      to_return(status: 200, body: response, headers: {})
  end
end

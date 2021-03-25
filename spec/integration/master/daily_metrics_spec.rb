RSpec.describe "Main process spec" do
  let(:today) { Time.zone.today.to_s }
  let(:yesterday) { Date.yesterday.to_s }

  let!(:an_edition) { create :edition }
  let!(:outdated_edition) { create :edition, content_id: "id1", base_path: "/path-1", live: false }
  let!(:edition) { create :edition, content_id: "id1", base_path: "/path-1", live: true }

  it "orchestrates all ETL processes" do
    stub_google_analytics_response
    stub_google_analytics_user_feedback_response
    stub_google_analytics_internal_search_response
    stub_feedex_response
    stub_monitoring

    Etl::Main::MainProcessor.process

    validate_facts_metrics!
    validate_google_analytics!
    validate_feedex!
    validate_aggregations!
    validate_monitoring!
    validate_search_views!
  end

  def live_version
    Dimensions::Edition.find_by(live: true, content_id: "id1")
  end

  def latest_metric
    Facts::Metric
      .joins(:dimensions_edition)
      .where(dimensions_editions: { live: true, content_id: "id1" })
      .first
  end

  def validate_facts_metrics!
    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.pluck(:dimensions_edition_id)).to match_array([an_edition.id, live_version.id])
    expect(Facts::Metric.distinct.pluck(:dimensions_date_id)).to match_array(yesterday.to_date)
  end

  def validate_google_analytics!
    expect(latest_metric).to have_attributes(
      pviews: 11,
      upviews: 12,
    )
  end

  def validate_satisfaction_score!
    expect(latest_metric).to have_attributes(
      useful_yes: 1,
      useful_no: 1,
      satisfaction: 0.5,
    )
  end

  def validate_aggregations!
    expect(Aggregations::MonthlyMetric.count).to eq(2)

    aggregation = Aggregations::MonthlyMetric.find_by(dimensions_edition_id: live_version.id)
    expect(aggregation).to have_attributes(
      dimensions_month_id: Date.yesterday.strftime("%Y-%m"),
      dimensions_edition_id: live_version.id,
      pviews: 11,
      upviews: 12,
    )
  end

  def validate_feedex!
    expect(latest_metric).to have_attributes(feedex: 21)
  end

  def validate_monitoring!
    expect(GovukStatsd).to have_received(:count).at_least(1).times
  end

  def validate_search_views!
    expect(Aggregations::SearchLastThirtyDays.all).to_not be_empty
    expect(Aggregations::SearchLastThreeMonths.all).to_not be_empty
    expect(Aggregations::SearchLastSixMonths.all).to_not be_empty
    expect(Aggregations::SearchLastTwelveMonths.all).to_not be_empty
  end

  def stub_google_analytics_response
    allow(Etl::GA::ViewsAndNavigationService).to receive(:find_in_batches).and_yield(
      [
        {
          "page_path" => "/path-1",
          "pviews" => 11,
          "upviews" => 12,
          "date" => yesterday,
          "process_name" => "views",
        },
        {
          "page_path" => "/path2",
          "pviews" => 2,
          "upviews" => 2,
          "date" => yesterday,
          "process_name" => "views",
        },
      ],
    )
  end

  def stub_google_analytics_user_feedback_response
    allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(
      [
        {
          "page_path" => "/path-1",
          "useful_no" => 1,
          "useful_yes" => 12,
          "date" => yesterday,
          "process_name" => "user_feedback",
        },
        {
          "page_path" => "/path2",
          "useful_no" => 122,
          "useful_yes" => 1,
          "date" => yesterday,
          "process_name" => "user_feedback",
        },
      ],
    )
  end

  def stub_google_analytics_internal_search_response
    allow(Etl::GA::InternalSearchService).to receive(:find_in_batches).and_yield(
      [
        {
          "page_path" => "/path1",
          "searches" => 1,
          "date" => yesterday,
          "process_name" => "searches",
        },
        {
          "page_path" => "/path2",
          "searches" => 2,
          "date" => yesterday,
          "process_name" => "searches",
        },
      ],
    )
  end

  def stub_monitoring
    allow(GovukStatsd).to receive(:count)
  end

  def stub_feedex_response
    response = {
      'results': [{
        'date': yesterday,
        'path': "/path-1",
        'count': 21,
      },
                  {
                    'date': yesterday,
                    'path': "/path2",
                    'count': 1,
                  },
                  {
                    'date': yesterday,
                    'path': "/path3",
                    'count': 1,
                  }],
      'total_count': 3,
      'current_page': 1,
      'pages': 1,
      'page_size': 3,
    }.to_json

    stub_request(:get, "http://support-api.dev.gov.uk/feedback-by-day/#{yesterday}?page=1&per_page=10000")
      .to_return(status: 200, body: response, headers: {})
  end
end

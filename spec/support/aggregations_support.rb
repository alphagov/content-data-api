module AggregationsSupport
  def recalculate_aggregations!
    refresh_last_year_of_monthly_aggregations
    refresh_views
  end

private

  def refresh_last_year_of_monthly_aggregations
    Etl::Aggregations::Monthly.process(date: Date.today)

    12.times { |index| Etl::Aggregations::Monthly.process(date: index.month.ago) }
  end

  def refresh_views
    ::Aggregations::SearchLastThirtyDays.refresh
    ::Aggregations::SearchLastMonth.refresh
    ::Aggregations::SearchLastThreeMonths.refresh
    ::Aggregations::SearchLastSixMonths.refresh
    ::Aggregations::SearchLastTwelveMonths.refresh
  end
end

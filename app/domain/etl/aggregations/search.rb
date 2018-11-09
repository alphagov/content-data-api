class Etl::Aggregations::Search
  include Concerns::Traceable

  def self.process(*args)
    new(*args).process
  end

  def process
    time(process: :aggregations_thirty_days) { ::Aggregations::SearchLastThirtyDays.refresh }
    time(process: :aggregations_last_month) { ::Aggregations::SearchLastMonth.refresh }
    time(process: :aggregations_last_three_months) { ::Aggregations::SearchLastThreeMonths.refresh }
    time(process: :aggregations_last_six_months) { ::Aggregations::SearchLastSixMonths.refresh }
    time(process: :aggregations_last_twelve_months) { ::Aggregations::SearchLastTwelveMonths.refresh }
  end
end

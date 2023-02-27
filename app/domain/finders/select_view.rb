class Finders::SelectView
  include SpecificMonths
  attr_reader :date_range

  def initialize(date_range)
    @date_range = date_range
  end

  def run
    return GovukError.notify(InvalidDateRangeError.new("Invalid date range: #{date_range}")) unless valid_date_range?

    { model_name:, table_name: }
  end

private

  def model_name
    return ::Aggregations::MonthlyMetric if specified_month

    aggregations = {
      "last-month" => ::Aggregations::SearchLastMonth,
      "past-3-months" => ::Aggregations::SearchLastThreeMonths,
      "past-6-months" => ::Aggregations::SearchLastSixMonths,
      "past-year" => ::Aggregations::SearchLastTwelveMonths,
    }
    aggregations[date_range] || ::Aggregations::SearchLastThirtyDays
  end

  def table_name
    return "aggregations_monthly_metrics" if specified_month

    table_names = {
      "last-month" => "last_months",
      "past-3-months" => "last_three_months",
      "past-6-months" => "last_six_months",
      "past-year" => "last_twelve_months",
    }
    table_names[date_range] || "last_thirty_days"
  end

  def valid_date_range?
    specified_month || ["past-30-days", "last-month", "past-3-months", "past-6-months", "past-year"].include?(date_range)
  end

  def specified_month
    @specified_month ||= SpecificMonths::VALID_SPECIFIC_MONTHS.include?(date_range)
  end

  class InvalidDateRangeError < StandardError
  end
end

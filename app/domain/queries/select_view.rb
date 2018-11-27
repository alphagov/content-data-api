class Queries::SelectView
  attr_reader :date_range

  def initialize(date_range)
    @date_range = date_range
  end

  def run
    return GovukError.notify(InvalidDateRangeError.new("Invalid date range: #{date_range}")) unless valid_date_range?
    { model_name: model_name, table_name: table_name }
  end

private

  def model_name
    case date_range
    when 'last-month'
      Aggregations::SearchLastMonth
    when 'past-3-months'
      Aggregations::SearchLastThreeMonths
    when 'past-6-months'
      Aggregations::SearchLastSixMonths
    when 'past-year'
      Aggregations::SearchLastTwelveMonths
    else
      Aggregations::SearchLastThirtyDays
    end
  end

  def table_name
    case date_range
    when 'last-month'
      'last_months'
    when 'past-3-months'
      'last_three_months'
    when 'past-6-months'
      'last_six_months'
    when 'past-year'
      'last_twelve_months'
    else
      'last_thirty_days'
    end
  end

  def valid_date_range?
    ['past-30-days', 'last-month', 'past-3-months', 'past-6-months', 'past-year'].include?(date_range)
  end

  class InvalidDateRangeError < StandardError
  end
end

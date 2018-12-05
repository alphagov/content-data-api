class DateRange
  attr_reader :time_period
  attr_accessor :to, :from

  def initialize(time_period)
    @time_period = time_period
    @to = date_to_range[:to]
    @from = date_to_range[:from]
  end

  def self.valid?(time_period)
    time_period.in?(['past-30-days', 'last-month', 'past-3-months', 'past-6-months', 'past-year'])
  end

  def self.build(from:, to:)
    @from = from
    @to = to
  end

private

  def date_to_range
    case time_period
    when 'past-30-days'
      {
        from: (Date.yesterday - 29.days).to_s,
        to: Date.yesterday.to_s
      }
    when 'last-month'
      {
        from: Date.yesterday.last_month.beginning_of_month.to_s,
        to: Date.yesterday.last_month.end_of_month.to_s
      }
    when 'past-3-months'
      {
        from: ((Date.yesterday - 3.months) + 1.day).to_s,
        to: Date.yesterday.to_s
      }
    when 'past-6-months'
      {
        from: ((Date.yesterday - 6.months) + 1.day).to_s,
        to: Date.yesterday.to_s
      }
    when 'past-year'
      {
        from: ((Date.yesterday - 1.year) + 1.day).to_s,
        to: Date.yesterday.to_s
      }
    else
      raise ArgumentError.new(time_period)
    end
  end
end

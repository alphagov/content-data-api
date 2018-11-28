class DateRange
  attr_reader :time_period
  attr_accessor :to, :from

  def initialize(time_period)
    @time_period = time_period
    @to = date_to_range[:to]
    @from = date_to_range[:from]
  end

  def self.valid?(time_period)
    time_period.in?(['past-30-days', 'last-month', 'past-3-months', 'past-6-months', 'past-year', 'past-2-years'])
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
        from: (Date.today - 30.days).to_s,
        to: Date.today.to_s
      }
    when 'last-month'
      {
        from: Date.today.last_month.beginning_of_month.to_s,
        to: Date.today.last_month.end_of_month.to_s
      }
    when 'past-3-months'
      {
        from: (Date.today - 3.months).to_s,
        to: Date.today.to_s
      }
    when 'past-6-months'
      {
        from: (Date.today - 6.months).to_s,
        to: Date.today.to_s
      }
    when 'past-year'
      {
        from: (Date.today - 1.year).to_s,
        to: Date.today.to_s
      }
    when 'past-2-years'
      {
        from: (Date.today - 2.years).to_s,
        to: Date.today.to_s
      }
    else
      raise ArgumentError.new(time_period)
    end
  end
end

class DateRange
  attr_reader :time_period, :to, :from

  def initialize(time_period)
    @time_period = time_period
    @to = date_to_range[:to]
    @from = date_to_range[:from]
  end

private

  def date_to_range
    case time_period
    when 'last-30-days'
      {
        from: (Date.today - 30.days).to_s,
        to: Date.today.to_s
      }
    when 'last-month'
      {
        from: Date.today.last_month.beginning_of_month.to_s,
        to: Date.today.last_month.end_of_month.to_s
      }
    when 'last-3-months'
      {
        from: (Date.today - 3.months).to_s,
        to: Date.today.to_s
      }
    when 'last-6-months'
      {
        from: (Date.today - 6.months).to_s,
        to: Date.today.to_s
      }
    when 'last-year'
      {
        from: (Date.today - 1.year).to_s,
        to: Date.today.to_s
      }
    when 'last-2-years'
      {
        from: (Date.today - 2.years).to_s,
        to: Date.today.to_s
      }
    else
      raise ArgumentError.new(time_period)
    end
  end
end

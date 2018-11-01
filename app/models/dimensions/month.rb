class Dimensions::Month < ApplicationRecord
  validates :year, presence: true, numericality: { only_integer: true }
  validates :quarter, presence: true, numericality: { only_integer: true }, inclusion: { in: (1..4) }
  validates :month_number, presence: true, numericality: { only_integer: true }, inclusion: { in: (1..12) }
  validates :month_name, presence: true, inclusion: { in: ::Date::MONTHNAMES }
  validates :month_name_abbreviated, presence: true, inclusion: { in: ::Date::ABBR_MONTHNAMES }

  def self.build_from_string(month_s)
    year, month = *month_s.split('-')

    build Date.new(year.to_i, month.to_i, 1)
  end

  def self.current
    build(Date.today)
  end

  def self.build(date)
    new(
      id: format('%04d-%02d', date.year, date.month),
      month_number: date.month,
      month_name: date.strftime('%B'),
      month_name_abbreviated: date.strftime('%b'),
      year: date.year,
      quarter: ((date.month - 1) / 3) + 1,
    )
  end
end

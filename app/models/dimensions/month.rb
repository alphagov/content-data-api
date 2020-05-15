class Dimensions::Month < ApplicationRecord
  self.primary_key = :id

  validates :year, presence: true, numericality: { only_integer: true }
  validates :quarter, presence: true, numericality: { only_integer: true }, inclusion: { in: (1..4) }
  validates :month_number, presence: true, numericality: { only_integer: true }, inclusion: { in: (1..12) }
  validates :month_name, presence: true, inclusion: { in: ::Date::MONTHNAMES }
  validates :month_name_abbreviated, presence: true, inclusion: { in: ::Date::ABBR_MONTHNAMES }

  def self.current
    find_existing_or_create(Time.zone.today)
  end

  def self.create_with(date)
    month_dimension = build(date)
    month_dimension.save!
    month_dimension
  end

  def self.find_existing_or_create(date)
    find_by(id: format_id(date)) || create_with(date)
  end

  def self.build(date)
    new(
      id: format_id(date),
      month_number: date.month,
      month_name: date.strftime("%B"),
      month_name_abbreviated: date.strftime("%b"),
      year: date.year,
      quarter: ((date.month - 1) / 3) + 1,
    )
  end

  def self.format_id(date)
    sprintf(Date::DATE_FORMATS[:month_edition], date.year, date.month)
  end
end

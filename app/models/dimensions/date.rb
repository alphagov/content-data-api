class Dimensions::Date < ApplicationRecord
  self.primary_key = "date"

  scope :between, ->(from, to) { where("date BETWEEN ? AND ?", from, to) }

  def self.build(date)
    new(
      date: date,
      date_name: date.to_s(:govuk_date),
      date_name_abbreviated: date.to_s(:govuk_date_short),
      year: date.year,
      quarter: ((date.month - 1) / 3) + 1,
      month: date.month,
      month_name: date.strftime("%B"),
      month_name_abbreviated: date.strftime("%b"),
      week: date.cweek,
      day_of_year: date.yday,
      day_of_quarter: (date - date.beginning_of_quarter).to_i + 1,
      day_of_month: date.mday,
      day_of_week: date.strftime("%u").to_i,
      day_name: date.strftime("%A"),
      day_name_abbreviated: date.strftime("%a"),
      weekday_weekend: date.saturday? || date.sunday? ? "Weekend" : "Weekday",
    )
  end

  def self.create_with(date)
    date_dimension = build(date)
    date_dimension.save!
    date_dimension
  end

  def self.find_existing_or_create(date)
    find_by(date: date) || create_with(date)
  rescue ActiveRecord::RecordNotUnique
    find_by(date: date)
  end

  def self.exists?(date)
    Dimensions::Date.where(date: date).exists?
  end

  validates :date, presence: true

  validates :date_name, presence: true
  validates :date_name_abbreviated, presence: true

  validates :year,
            presence: true,
            numericality: { only_integer: true }

  validates :quarter,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..4) }

  validates :month,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..12) }

  validates :month_name,
            presence: true,
            inclusion: { in: ::Date::MONTHNAMES }

  validates :month_name_abbreviated,
            presence: true,
            inclusion: { in: ::Date::ABBR_MONTHNAMES }

  validates :week,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..53) }

  validates :day_of_year,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..366) }

  validates :day_of_quarter,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..124) }

  validates :day_of_month,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..31) }

  validates :day_of_week,
            presence: true,
            numericality: { only_integer: true },
            inclusion: { in: (1..7) }

  validates :day_name,
            presence: true,
            inclusion: { in: ::Date::DAYNAMES }

  validates :day_name_abbreviated,
            presence: true,
            inclusion: { in: ::Date::ABBR_DAYNAMES }

  validates :weekday_weekend,
            presence: true,
            inclusion: { in: %w[Weekday Weekend] }
end

module SpecificMonths
  YEARS = (2018..Time.zone.today.year).to_a.freeze
  MONTHS = Date::MONTHNAMES.compact.freeze

  VALID_SPECIFIC_MONTHS = YEARS.flat_map do |year|
    MONTHS.map do |month|
      "#{month.downcase}-#{year}"
    end
  end
end

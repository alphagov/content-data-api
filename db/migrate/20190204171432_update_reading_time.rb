class UpdateReadingTime < ActiveRecord::Migration[5.2]
  class Facts::Edition < ApplicationRecord
  end

  class Dimensions::Edition < ApplicationRecord
    has_one :facts_edition, class_name: "Facts::Edition", foreign_key: :dimensions_edition_id
  end

  def up
    Dimensions::Edition.where(latest: true).find_each do |edition|
      facts = edition.facts_edition
      if facts.words.present? && facts.words.positive?
        reading_time = Etl::Edition::Content::ReadingTime.calculate(facts.words)
        facts.update(reading_time: reading_time)
      end
    end
  end
end

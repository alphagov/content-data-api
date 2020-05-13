class Facts::Edition < ApplicationRecord
  belongs_to :dimensions_date, class_name: "Dimensions::Date"
  belongs_to :dimensions_edition, class_name: "Dimensions::Edition"

  validates :dimensions_date, presence: true
  validates :dimensions_edition, presence: true

  scope :between, lambda { |from, to|
    joins(:dimensions_date)
      .where("dimensions_dates.date BETWEEN ? AND ?", from, to)
  }

  def clone_for!(new_dim_edition, new_date)
    new_facts_edition = dup
    new_facts_edition.assign_attributes(dimensions_edition: new_dim_edition, dimensions_date: new_date)
    new_facts_edition.save!
    new_facts_edition
  end
end

class Theme < ApplicationRecord
  default_scope { order(:name) }

  has_many :subthemes
  has_many :inventory_rules, through: :subthemes

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def option_name
    "All #{name}"
  end

  def option_value
    "Theme_#{id}"
  end
end

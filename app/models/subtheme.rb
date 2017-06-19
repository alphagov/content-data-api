class Subtheme < ApplicationRecord
  belongs_to :theme
  has_many :inventory_rules

  validates :name,
    presence: true,
    uniqueness: { scope: :theme, case_sensitive: false }
end

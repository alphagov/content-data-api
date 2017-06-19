class Theme < ApplicationRecord
  default_scope { order(:name) }

  has_many :subthemes
  has_many :inventory_rules, through: :subthemes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

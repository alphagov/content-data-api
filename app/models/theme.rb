class Theme < ApplicationRecord
  has_many :subthemes
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

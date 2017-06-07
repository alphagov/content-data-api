class Theme < ApplicationRecord
  has_many :subthemes
  validates :name, presence: true
end

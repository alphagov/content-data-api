class Dimensions::Organisation < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true
  validates :link, presence: true
  validates :content_id, presence: true
  validates :state, presence: true
end

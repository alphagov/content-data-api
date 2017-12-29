class Dimensions::Item < ApplicationRecord
  validates :content_id, presence: true
end

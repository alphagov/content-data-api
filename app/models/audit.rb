class Audit < ApplicationRecord
  belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id
  belongs_to :user, primary_key: :uid, foreign_key: :uid

  validates :content_item, presence: true
  validates :user, presence: true
end

class Audit < ApplicationRecord
  belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id
  belongs_to :user, primary_key: :uid, foreign_key: :uid

  has_many :responses, inverse_of: :audit
  has_many :questions, through: :responses

  validates :content_item, presence: true
  validates :user, presence: true

  accepts_nested_attributes_for :responses

  def template
    @template ||= Template.new
  end
end

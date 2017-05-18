class Response < ApplicationRecord
  belongs_to :audit
  belongs_to :question

  validates :audit, presence: true
  validates :question, presence: true
end

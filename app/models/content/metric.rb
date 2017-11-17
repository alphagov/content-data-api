module Content
  class Metric < ApplicationRecord
    self.table_name = 'metrics'

    belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id,
                class_name: 'Content::Item'

    validates :content_id, presence: true
    validates :date, presence: true
  end
end

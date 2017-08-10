module Audits
  class Allocation < ApplicationRecord
    belongs_to :user, primary_key: :uid, foreign_key: :uid
    belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id, class_name: 'Content::Item'
  end
end

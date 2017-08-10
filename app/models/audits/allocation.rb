module Audits
  class Allocation < ApplicationRecord
    belongs_to :user
    belongs_to :content_item
  end
end

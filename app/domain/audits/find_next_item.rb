module Audits
  class FindNextItem
    def self.call(content_item, filter)
      filter.after = content_item
      filter.page = nil

      FindContent.call(filter).first
    end
  end
end

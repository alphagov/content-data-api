module Audits
  class FindNextItem
    def self.call(content_item, filter)
      filter.after = content_item
      filter.page = 1
      filter.per_page = 1

      FindContent.paged(filter).first
    end
  end
end

module Audits
  class Monitor
    attr_accessor :filter

    def initialize(filter)
      self.filter = filter
    end

    def total_count
      content_items.count
    end

    def audited_count
      Policies::Audited.call(content_items).count
    end

    def not_audited_count
      Policies::NonAudited.call(content_items).count
    end

    def passing_count
      Policies::Passed.call(content_items).count
    end

    def not_passing_count
      Policies::Failed.call(content_items).count
    end

    def audited_percentage
      percentage(audited_count, out_of: total_count)
    end

    def not_audited_percentage
      percentage(not_audited_count, out_of: total_count)
    end

    def passing_percentage
      percentage(passing_count, out_of: audited_count)
    end

    def not_passing_percentage
      percentage(not_passing_count, out_of: audited_count)
    end

  private

    def content_items
      @content_items ||= FindContent.call(filter).limit(nil).offset(nil)
    end

    def percentage(number, out_of:)
      return 0 if out_of.zero?
      number.to_f / out_of * 100
    end
  end
end

module Audits
  class UnallocateContent
    def self.call(*args)
      new(*args).call
    end

    attr_accessor :content_ids

    def initialize(content_ids:)
      self.content_ids = content_ids
    end

    def call
      Allocation.where(content_id: content_ids).delete_all

      Result.new(content_ids)
    end

    class Result
      attr_reader :content_ids

      def initialize(content_ids)
        @content_ids = content_ids
      end

      def message
        "#{content_ids.length} items unallocated"
      end
    end
  end
end

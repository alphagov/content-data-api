module Metrics
  class NumberOfPdfsMetric
    attr_accessor :content_item

    def initialize(content_item)
      @content_item = content_item
    end

    def run
    end
  end
end

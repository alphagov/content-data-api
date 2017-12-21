module Performance::Metrics
  class PagesWithWordFiles
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def run
      percentage = 0
      total = scope.where("number_of_word_files > ?", 0).count

      percentage = (total.to_f / scope.count.to_f) * 100 if total.positive?

      {
        pages_with_word_files: {
          value: total,
          percentage: percentage
        }
      }
    end
  end
end

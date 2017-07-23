module Performance::Metrics
  class PagesWithPdfs
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def run
      percentage = 0
      total = scope.where("number_of_pdfs > ?", 0).count

      percentage = (total.to_f / scope.count.to_f) * 100 if total.positive?

      {
        pages_with_pdfs: {
          value: total,
          percentage: percentage
        }
      }
    end
  end
end

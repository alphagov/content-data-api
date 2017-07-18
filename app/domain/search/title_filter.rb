class Search
  class TitleFilter
    attr_accessor :text

    def initialize(text)
      self.text = text
    end

    def apply(scope)
      scope.where("title like ?", "%#{text}%")
    end
  end
end

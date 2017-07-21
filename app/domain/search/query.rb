class Search
  Query = ValueStruct.new(:filters, :per_page, :page, :sort, :previous_content_item) do
    def deep_clone
      Marshal.load(Marshal.dump(self))
    end

    def build
      self
    end
  end
end

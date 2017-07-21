class Search
  Query = ValueStruct.new(:filters, :per_page, :page, :sort) do
    def deep_clone
      Marshal.load(Marshal.dump(self))
    end
  end
end

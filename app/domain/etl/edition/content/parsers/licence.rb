module Etl::Edition::Content::Parsers
  class Licence
    def parse(json)
      ContentArray.new.parse(json.dig("details", "licence_overview"))
    end

    def schemas
      %w[licence]
    end
  end
end

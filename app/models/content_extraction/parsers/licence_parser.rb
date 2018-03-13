class ContentExtraction::Parsers::LicenceParser
  def parse(json)
    json.dig("details", "licence_overview")
  end
end
ContentExtraction::ContentParser.register('licence', ContentExtraction::Parsers::LicenceParser.new)

class Parsers::LicenceParser
  def parse(json)
    json.dig("details", "licence_overview")
  end
end
Parsers::ContentExtractors.register('licence', Parsers::LicenceParser.new)

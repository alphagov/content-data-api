class Content::Parsers::Licence
  def parse(json)
    json.dig("details", "licence_overview")
  end
end
Content::Parser.register('licence', Content::Parsers::Licence.new)

class Item::Content::Parsers::Licence
  def parse(json)
    json.dig("details", "licence_overview")
  end

  def schemas
    ['licence']
  end
end

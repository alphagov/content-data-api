class Item::Content::Parsers::Finder
  def parse(json)
    html = []
    html << json.dig("title") unless json.dig("title").nil?
    children = json.dig("links", "children")
    unless children.nil?
      children.each do |child|
        html << child["title"]
        html << child["description"]
      end
    end
    html.join(" ") unless html.empty?
  end

  def schemas
    ['finder']
  end
end

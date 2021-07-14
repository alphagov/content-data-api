class Etl::Edition::Content::Parsers::Finder
  def parse(json)
    html = []
    html << json["title"] unless json["title"].nil?
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
    %w[finder]
  end
end

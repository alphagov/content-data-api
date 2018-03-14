class Content::Parsers::Taxon
  def parse(json)
    html = []
    html << json.dig("description")
    return unless json.dig("links").include?("child_taxons")
    children = json.dig("links", "child_taxons")
    children.each do |child|
      html << child["title"]
      html << child["description"]
    end
    html.join(" ")
  end
end
Content::Parser.register('taxon',
  Content::Parsers::Taxon.new)

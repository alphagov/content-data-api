class Etl::Item::Content::Parsers::ServiceManualStandard
  def parse(json)
    html = []
    html << json.dig('title')
    html << json.dig('details', 'body')
    children = json.dig('links', 'children')
    unless children.nil?
      children.each do |child|
        html << child['title']
        html << child['description']
      end
    end
    html.join(" ")
  end

  def schemas
    ['service_manual_service_standard']
  end
end

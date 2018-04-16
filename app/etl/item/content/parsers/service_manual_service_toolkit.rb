class Item::Content::Parsers::ServiceManualServiceToolkit
  def parse(json)
    html = []
    json.dig('details', 'collections').each do |item|
      html << item['title']
      html << item['description']
      item.dig('links').each do |link|
        html << link['title']
        html << link['description']
      end
    end
    html.join(' ')
  end

  def schemas
    ['service_manual_service_toolkit']
  end
end

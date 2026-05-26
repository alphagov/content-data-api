class Etl::Edition::Content::Parsers::Navigation
  def parse(json)
    html = []
    html << json.dig("details", "menu_items").map { |item| item["content_id"] }.join(" ")
    html.join(" ")
  end

  def schemas
    %w[navigation]
  end
end

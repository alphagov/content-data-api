class Etl::Edition::Content::Parsers::Mainstream
  def parse(json)
    html = []
    html << json["title"] unless json["title"].nil?
    html << json["description"] unless json["description"].nil?

    children = json.dig("links", "children")
    if children.present?
      children.each do |child|
        html << child["title"]
      end
    end

    related_topics = json.dig("links", "related_topics")
    if related_topics.present?
      related_topics.each do |topic|
        html << topic["title"]
      end
    end

    html.compact.join(" ")
  end

  def schemas
    %w[mainstream_browse_page]
  end
end

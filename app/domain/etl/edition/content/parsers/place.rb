class Etl::Edition::Content::Parsers::Place
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "more_information")
    html.join(" ")
  end

  def schemas
    %w[place]
  end
end

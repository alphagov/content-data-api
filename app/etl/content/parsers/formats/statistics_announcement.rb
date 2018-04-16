class Content::Parsers::Formats::StatisticsAnnouncement
  def parse(json)
    html = []
    html << json.dig("description")
    html << json.dig("details", "display_date")
    html << json.dig("details", "state")
    html.join(" ")
  end

  def schemas
    ['statistics_announcement']
  end
end

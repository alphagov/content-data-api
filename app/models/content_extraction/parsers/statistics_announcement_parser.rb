class ContentExtraction::Parsers::StatisticsAnnouncementParser
  def parse(json)
    html = []
    html << json.dig("description")
    html << json.dig("details", "display_date")
    html << json.dig("details", "state")
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register('statistics_announcement',
  ContentExtraction::Parsers::StatisticsAnnouncementParser.new)

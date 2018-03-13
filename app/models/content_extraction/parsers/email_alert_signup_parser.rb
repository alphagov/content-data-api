class ContentExtraction::Parsers::EmailAlertSignupParser
  def parse(json)
    html = []
    json.dig("details", "breadcrumbs").each do |crumb|
      html << crumb["title"]
    end
    html << json.dig("details", "summary")
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register('email_alert_signup', ContentExtraction::Parsers::EmailAlertSignupParser.new)

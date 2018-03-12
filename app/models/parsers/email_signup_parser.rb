class Parsers::EmailSignupParser
  def parse(json)
    html = []
    json.dig("details", "breadcrumbs").each do |crumb|
      html << crumb["title"]
    end
    html << json.dig("details", "summary")
    html.join(" ")
  end
end
Parsers::ContentExtractors.register('email_alert_signup', Parsers::EmailSignupParser.new)

class Content::Parsers::EmailAlertSignup
  def parse(json)
    html = []
    json.dig("details", "breadcrumbs").each do |crumb|
      html << crumb["title"]
    end
    html << json.dig("details", "summary")
    html.join(" ")
  end
end
Content::Parser.register('email_alert_signup', Content::Parsers::EmailAlertSignup.new)

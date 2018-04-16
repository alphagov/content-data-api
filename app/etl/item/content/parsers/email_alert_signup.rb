class Item::Content::Parsers::EmailAlertSignup
  def parse(json)
    html = []
    json.dig("details", "breadcrumbs").each do |crumb|
      html << crumb["title"]
    end
    html << json.dig("details", "summary")
    html.join(" ")
  end

  def schemas
    ['email_alert_signup']
  end
end

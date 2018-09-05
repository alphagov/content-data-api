class Etl::Item::Content::Parsers::EmailAlertSignup
  def parse(json)
    html = []
    breadcrumbs = json.dig("details", "breadcrumbs")
    unless breadcrumbs.nil?
      breadcrumbs.each do |crumb|
        html << crumb["title"]
      end
    end
    html << json.dig("details", "summary")
    html.join(" ")
  end

  def schemas
    %w[email_alert_signup]
  end
end

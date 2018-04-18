class Item::Content::Parsers::FinderEmailSignup
  def parse(json)
    html = []
    json.dig("details", "email_signup_choice").each do |choice|
      html << choice["radio_button_name"]
    end
    html << json.dig("description")
    html.join(" ")
  end

  def schemas
    ['finder_email_signup']
  end
end

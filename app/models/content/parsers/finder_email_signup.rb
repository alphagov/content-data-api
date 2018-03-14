class Content::Parsers::FinderEmailSignup
  def parse(json)
    html = []
    json.dig("details", "email_signup_choice").each do |choice|
      html << choice["radio_button_name"]
    end
    html << json.dig("description")
    html.join(" ")
  end
end
Content::Parser.register('finder_email_signup', Content::Parsers::FinderEmailSignup.new)

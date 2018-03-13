class Parsers::FinderEmailSignupParser
  def parse(json)
    html = []
    json.dig("details", "email_signup_choice").each do |choice|
      html << choice["radio_button_name"]
    end
    html << json.dig("description")
    html.join(" ")
  end
end
Parsers::ContentExtractors.register('finder_email_signup', Parsers::FinderEmailSignupParser.new)

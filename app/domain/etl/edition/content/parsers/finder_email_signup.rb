class Etl::Edition::Content::Parsers::FinderEmailSignup
  def parse(json)
    html = []
    choices = json.dig("details", "email_signup_choice")
    unless choices.nil?
      choices.each do |choice|
        html << choice["radio_button_name"]
      end
    end
    html << json["description"]
    html.join(" ")
  end

  def schemas
    %w[finder_email_signup]
  end
end

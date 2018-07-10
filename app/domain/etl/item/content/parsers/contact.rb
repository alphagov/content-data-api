class Etl::Item::Content::Parsers::Contact
  def parse(json)
    html = []
    html << json.dig('details', 'description')
    html << get_email(json) unless get_email(json).nil?
    html << get_postal(json) unless get_postal(json).nil?
    html << get_phone(json) unless get_phone(json).nil?
    html.join(" ")
  end

  def schemas
    ['contact']
  end

private

  def get_phone(json)
    html = []
    phones = json.dig('details', 'phone_numbers')
    unless phones.nil?
      phones.each do |phone|
        html << phone['title']
        html << phone['description']
      end
    end
    more_info = json.dig('details', 'more_info_phone_number')
    html << more_info unless more_info.nil?
  end

  def get_postal(json)
    html = []
    postal = json.dig('details', 'post_addresses')
    unless postal.nil?
      postal.each do |addr|
        html << addr['title']
        html << addr['description']
      end
    end
    more_info = json.dig('details', 'more_info_post_address')
    html << more_info unless more_info.nil?
  end

  def get_email(json)
    html = []
    emails = json.dig('details', 'email_addresses')
    unless emails.nil?
      emails.each do |addr|
        html << addr['title']
        html << addr['description']
      end
    end
    more_info = json.dig('details', 'more_info_email_address')
    html << more_info unless more_info.nil?
  end
end

class Item::Metadata::Parsers::PrimaryOrganisation
  def self.parse(raw_json)
    primary_org = raw_json.dig('links', 'primary_publishing_organisation') || []
    if primary_org.any?
      {
        primary_organisation_content_id: primary_org[0].fetch('content_id'),
        primary_organisation_title: primary_org[0].fetch('title'),
        primary_organisation_withdrawn: primary_org[0].fetch('withdrawn')
      }
    else
      {}
    end
  end
end

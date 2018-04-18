class Item::Metadata::Parsers::PrimaryOrganisation
  def self.parse(raw_json)
    return {} unless raw_json
    links = raw_json['links']
    return {} unless links && links['primary_publishing_organisation']
    org = links['primary_publishing_organisation'].first
    return {} unless org
    {
      primary_organisation_content_id: org['content_id'],
      primary_organisation_title: org['title'],
      primary_organisation_withdrawn: org['withdrawn']
    }
  end
end

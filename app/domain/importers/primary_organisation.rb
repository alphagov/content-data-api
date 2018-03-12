class Importers::PrimaryOrganisation
  def self.parse(links)
    return {} unless links && links['primary_publishing_organisation']
    org = links['primary_publishing_organisation'].first
    {
      primary_organisation_content_id: org['content_id'],
      primary_organisation_title: org['title'],
      primary_organisation_withdrawn: org['withdrawn']
    }
  end
end

class Organisation < ApplicationRecord
  has_many :content_items

  def self.import
    url = "https://www.gov.uk/api/search.json?start=0&facet_organisations=10000&count=0"
    response_body = RestClient.get(url).body
    facets = JSON.parse(response_body)['facets']
    if facets.present? && facets["organisations"].present? &&
        facets["organisations"]["options"].present?
      facets["organisations"]["options"].each do |organisation|
        attributes = organisation["value"].slice("content_id", "slug")
        self.create(attributes.merge(number_of_pages: organisation["documents"]))
      end
    end
  end
end

module Importers
  class AllTaxons
    attr_accessor :taxonomies_service

    def initialize
      @taxonomies_service = TaxonomiesService.new
    end

    def run
      taxonomies_service.find_each do |attributes|
        content_id = attributes.fetch(:content_id)
        taxonomy = Taxonomy.find_or_create_by(content_id: content_id)
        taxonomy.update!(attributes.slice(:title, :content_id))
      end
    end
  end
end

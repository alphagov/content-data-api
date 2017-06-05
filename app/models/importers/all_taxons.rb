module Importers
  class AllTaxons
    attr_accessor :taxons

    def initialize
      @taxons = TaxonomyService.new
    end

    def run
      taxons.find_each do |attributes|
        content_id = attributes.fetch(:content_id)
        taxon = Taxon.find_or_create_by(content_id: content_id)
        taxon.update!(attributes.slice(:title, :content_id))
      end
    end
  end
end

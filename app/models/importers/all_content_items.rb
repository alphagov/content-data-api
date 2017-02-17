module Importers
  class AllContentItems
    def run
      content_item_importer = ContentItemsByOrganisation.new

      Organisation.find_each do |organisation|
        content_item_importer.run(organisation.slug)
      end
    end
  end
end

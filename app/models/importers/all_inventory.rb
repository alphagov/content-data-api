module Importers
  class AllInventory
    def run
      Importers::AllOrganisations.new.run
      Importers::AllTaxons.new.run
      Importers::AllContentItems.new.run
    end
  end
end

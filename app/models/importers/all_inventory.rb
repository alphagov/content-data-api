module Importers
  class AllInventory
    def run
      Importers::AllTaxons.new.run
      Importers::AllContentItems.new.run
    end
  end
end

module Importers
  class AllInventory
    def run
      Importers::AllContentItems.new.run
    end
  end
end

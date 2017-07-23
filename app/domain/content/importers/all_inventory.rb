module Content
  class Importers::AllInventory
    def run
      Importers::AllContentItems.new.run
    end
  end
end

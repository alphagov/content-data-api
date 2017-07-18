RSpec.describe Importers::AllInventory do
  describe '#run' do
    it 'imports all the inventory' do
      expect_any_instance_of(Importers::AllContentItems).to receive(:run)

      Importers::AllInventory.new.run
    end
  end
end

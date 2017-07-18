require 'rake'

RSpec.describe 'Import organisation rake task' do
  describe 'import:all_content_items' do
    before do
      Rake::Task['import:all_content_items'].reenable
    end

    it 'runs the processs to import all content items' do
      expect_any_instance_of(Importers::AllContentItems).to receive(:run)

      Rake::Task['import:all_content_items'].invoke
    end
  end

  describe 'import:all_inventory' do
    before do
      Rake::Task['import:all_inventory'].reenable
    end

    it 'runs the all_inventory task' do
      expect_any_instance_of(Importers::AllInventory).to receive(:run)

      Rake::Task['import:all_inventory'].invoke
    end
  end

  describe 'import:all_ga_metrics' do
    before do
      Rake::Task['import:all_ga_metrics'].reenable
    end

    it 'runs the all_ga_metrics task' do
      expect_any_instance_of(Importers::AllGoogleAnalyticsMetrics).to receive(:run)

      Rake::Task['import:all_ga_metrics'].invoke
    end
  end
end

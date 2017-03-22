require 'rails_helper'
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

  describe 'import:all_organisations' do
    before do
      Rake::Task['import:all_organisations'].reenable
    end

    it 'runs the process to import all organisations' do
      expect_any_instance_of(Importers::AllOrganisations).to receive(:run)

      Rake::Task['import:all_organisations'].invoke
    end
  end

  describe 'import:all_taxons' do
    before do
      Rake::Task['import:all_taxons'].reenable
    end

    it 'runs the process to import all taxons' do
      expect_any_instance_of(Importers::AllTaxons).to receive(:run)

      Rake::Task['import:all_taxons'].invoke
    end
  end

  describe 'import:number_of_views_by_organisation' do
    before do
      Rake::Task['import:number_of_views_by_organisation'].reenable
    end

    it 'raises an error if a slug parameter is not present' do
      expect { Rake::Task['import:number_of_views_by_organisation'].invoke }.to raise_error('Missing slug parameter')
    end

    it 'runs the number_of_views_by_organisation task' do
      expect_any_instance_of(Importers::NumberOfViewsByOrganisation).to receive(:run).with('a_slug')

      Rake::Task['import:number_of_views_by_organisation'].invoke('a_slug')
    end
  end
end

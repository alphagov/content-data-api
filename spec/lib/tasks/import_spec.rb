require 'rails_helper'
require 'rake'


RSpec.describe 'Import organisation rake task' do
  describe 'import:organisation' do
    before do
      Rake::Task['import:organisation'].reenable
    end

    it 'runs the process to import the organisations' do
      importer = double('importer')
      expect(Importers::Organisation).to receive(:new).with('a_slug').and_return(importer)
      expect(importer).to receive(:run)

      Rake::Task['import:organisation'].invoke('a_slug')
    end

    it 'raises an error if a slug parameter is not present' do
      expect { Rake::Task['import:organisation'].invoke }.to raise_error('Missing slug parameter')
    end
  end
  describe 'import:all_organisations' do
    before do
      Rake::Task['import:all_organisations'].reenable
    end

    it 'runs the process to import all organisations' do
      expect_any_instance_of(Importers::Organisations).to receive(:import_all)

      Rake::Task['import:all_organisations'].invoke('a_slug')
    end
  end
end

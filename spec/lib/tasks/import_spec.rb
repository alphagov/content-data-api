require 'rails_helper'
require 'rake'


RSpec.describe 'Import organisation rake task' do
  before(:all) do
    Rails.application.load_tasks
  end

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

    it 'raise an error if a slug is not provided' do
      expect { Rake::Task['import:organisation'].invoke }.to raise_error('Missing slug parameter')
    end
  end
end

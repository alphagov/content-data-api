require 'rails_helper'
require 'rake'


RSpec.describe 'Import organisation rake task' do
  describe 'import:organisation' do
    before do
      Rake::Task['import:organisation'].reenable
    end

    let(:importer) { double('importer') }

    it 'runs the process to import the organisations' do
      expect(Importers::Organisation).to receive(:new).with('a_slug', anything).and_return(importer)
      expect(importer).to receive(:run)

      Rake::Task['import:organisation'].invoke('a_slug')
    end

    it 'pass the logger to the importer' do
      expect(Importers::Organisation).to receive(:new).with(anything, hash_including(logger: instance_of(Logger))).and_return(importer)
      allow(importer).to receive(:run)

      Rake::Task['import:organisation'].invoke('a-string')
    end

    it 'raises an error if a slug parameter is not present' do
      expect { Rake::Task['import:organisation'].invoke }.to raise_error('Missing slug parameter')
    end
  end
end

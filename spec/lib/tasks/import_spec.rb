require 'rails_helper'
require 'rake'

RSpec.describe 'Import organisation rake task' do
  describe 'import:organisation' do
    before do
      Rake::Task['import:organisation'].reenable
    end

    it 'runs the process to import the organisations' do
      expect_any_instance_of(Importers::Organisation).to receive(:run)

      Rake::Task['import:organisation'].invoke('a_slug')
    end

    describe 'Importer parameters' do
      let(:importer) { instance_double(Importers::Organisation, run: nil) }

      it 'raises an error if a slug parameter is not present' do
        expect { Rake::Task['import:organisation'].invoke }.to raise_error('Missing slug parameter')
      end

      it 'receives the slug' do
        expected = 'a-slug'
        expect(Importers::Organisation).to receive(:new).with(expected, anything).and_return(importer)

        Rake::Task['import:organisation'].invoke('a-slug')
      end

      it 'receives the logger' do
        expected = hash_including(logger: instance_of(Logger))
        expect(Importers::Organisation).to receive(:new).with(anything, expected).and_return(importer)

        Rake::Task['import:organisation'].invoke('a-string')
      end
    end
  end
end

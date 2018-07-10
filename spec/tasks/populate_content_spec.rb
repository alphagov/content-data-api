RSpec.describe 'rake etl:populate_content' do
 it 'calls Etl::Item::Content::ContentPopulator.process' do
   processor = class_double(Etl::Item::Content::ContentPopulator, process: true).as_stubbed_const
   expect(processor).to receive(:process)

   Rake::Task['etl:populate_content'].invoke
 end
end

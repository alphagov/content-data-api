namespace :etl do
  desc 'Populate document_text property for items which have no content'
  task populate_content: :environment do
    Etl::Item::Content::ContentPopulator.process
  end
end

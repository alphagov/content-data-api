namespace :etl do
  task populate_content: :environment do
    Etl::Item::Content::ContentPopulator.process
  end
end

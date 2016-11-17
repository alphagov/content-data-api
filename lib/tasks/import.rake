namespace :import do
  desc "import all organisations and respective content items"
  task all: :environment do
    Rake::Task["import:organisations"].invoke
    Rake::Task["import:contentitems"].invoke
  end

  desc "import all organisations"
  task organisations: :environment do
    Organisation.import
  end

  desc "import all content items for each organisation"
  task contentitems: :environment do
    ContentItem.import
  end
end

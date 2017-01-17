namespace :import do
  desc 'Creates / Updates all the content items belonging to an organisation'
  task :content_items_by_organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::ContentItemsByOrganisation.new.run(args.slug)
  end

  desc 'Import all organisations (without content items)'
  task all_organisations: :environment do
    Importers::AllOrganisations.new.run
  end

  desc 'Update the number of page views for all content items belonging to an organisation'
  task :number_of_views_by_organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::NumberOfViewsByOrganisation.new.run(args.slug)
  end
end

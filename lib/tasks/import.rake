namespace :import do
  desc 'Import all the content items belonging to an organisation'
  task :content_items_by_organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::ContentItemsByOrganisation.new.run(args.slug)
  end

  desc 'Import all organisations'
  task all_organisations: :environment do
    Importers::AllOrganisations.new.run
  end
end

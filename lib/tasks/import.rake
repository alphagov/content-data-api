namespace :import do
  desc 'Import an organisation\'s details and content items'
  task :organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::Organisation.new(args.slug).run
  end

  desc 'Import all organisations'
  task all_organisations: :environment do
    Importers::AllOrganisations.new.run
  end
end

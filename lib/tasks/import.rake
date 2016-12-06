namespace :import do
  desc 'Import an organisation\'s details and content items'
  task :organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::Organisation.new(args.slug).run
  end
end

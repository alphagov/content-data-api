namespace :import do
  task :organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::Organisation.run(args.slug)
  end
end
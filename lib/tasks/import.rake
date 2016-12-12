namespace :import do
  desc 'Import an organisation\'s details and content items'
  task :organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO

    Importers::Organisation.new(args.slug, logger: logger).run
  end
end

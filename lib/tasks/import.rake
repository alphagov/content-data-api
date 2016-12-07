namespace :import do
  desc 'Import an organisation\'s details and content items'
  task :organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.level = Logger::INFO

    Importers::Organisation.new(args.slug).run
  end
end

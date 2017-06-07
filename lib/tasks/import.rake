namespace :import do
  desc 'Import all organisations (without content items)'
  task all_organisations: :environment do
    Importers::AllOrganisations.new.run
  end

  desc 'Import all content items for all organisations'
  task all_content_items: :environment do
    Importers::AllContentItems.new.run
  end

  desc 'Import all taxons (without content items)'
  task all_taxons: :environment do
    Importers::AllTaxons.new.run
  end

  desc 'Update the number of page views for all content items belonging to an organisation'
  task :number_of_views_by_organisation, [:slug] => :environment do |_, args|
    raise 'Missing slug parameter' unless args.slug

    Importers::NumberOfViewsByOrganisation.new.run(args.slug)
  end

  desc 'Import all the inventory'
  task all_inventory: :environment do
    Importers::AllInventory.new.run
  end

  desc 'Import GA metrics '
  task all_ga_metrics: :environment do
    Importers::AllGoogleAnalyticsMetrics.new.run
  end

  desc 'Import todos for taxonomy project'
  task :todos_for_taxonomy_project, [:name, :csv_url] => :environment do |_, args|
    csv = RemoteCsv.new(args.csv_url)
    Importers::TodosForTaxonomyProject.new(args.name, csv).run
  end
end

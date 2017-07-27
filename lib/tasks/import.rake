namespace :import do
  desc 'Import all content items for all organisations'
  task all_content_items: :environment do
    Content::Importers::AllContentItems.new.run
  end

  desc 'Import all taxons (without content items)'
  task all_taxons: :environment do
    Importers::AllTaxons.new.run
  end

  desc 'Import all the inventory'
  task all_inventory: :environment do
    Content::Importers::AllInventory.new.run
  end

  desc 'Import GA metrics '
  task all_ga_metrics: :environment do
    Content::Importers::AllGoogleAnalyticsMetrics.new.run
  end

  desc 'Import todos for term_generation project'
  task :todos_for_taxonomy_project, [:name, :csv_url] => :environment do |_, args|
    csv = RemoteCsv.new(args.csv_url)
    project = TaxonomyProject.create(args.name)
    importer = TermGeneration::Importers::TodosForTaxonomyProject.new(project, csv)
    importer.run
    puts "Imported #{importer.completed.size} with #{importer.errors.size} errors"
  end
end

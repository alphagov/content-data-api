namespace :term_generation do
  desc "Create a CSV of term generation project Rate of Discovery statistics"
  task :create_project_statistics_csv, [:project_id] => :environment do |_, args|
    project = TaxonomyProject.find(args.project_id)
    data = TermGeneration::RateOfDiscovery.calculate(project)
    filename = "tmp/#{project.name.parameterize}.csv"

    CSV.open(filename, "wb") do |csv|
      csv << %w[count moving_average]
      data.each_with_index do |datum, index|
        csv << [index, datum]
      end
    end

    puts "Written #{data.length} stats to #{filename}"
  end
end

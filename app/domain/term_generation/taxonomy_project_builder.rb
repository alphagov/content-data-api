module TermGeneration
  class TaxonomyProjectBuilder
    def self.build(name:, csv_url:)
      TaxonomyProject.create!(name: name).tap do |project|
        csv = RemoteCsv.new(csv_url)
        importer = TermGeneration::Importers::TodosForTaxonomyProject.new(project, csv)
        importer.run
      end
    end
  end
end

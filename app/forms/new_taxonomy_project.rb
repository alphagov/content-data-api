class NewTaxonomyProject
  include ActiveModel::Model
  attr_accessor :name, :csv_url

  def save
    project = create_project
    create_todos(project)
  end

  def project_id
    create_project.id
  end

private

  def create_project
    @project ||= TaxonomyProject.create!(name: name)
  end

  def create_todos(project)
    csv = RemoteCsv.new(csv_url)
    importer = TermGeneration::Importers::TodosForTaxonomyProject.new(project, csv)
    importer.run
  end
end

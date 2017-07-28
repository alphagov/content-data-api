class TaxonomyProjectsController < ApplicationController
  def index
    @projects = TaxonomyProject.all
  end

  def show
    @project = TaxonomyProject.find(params[:id])
  end

  def new
  end

  def create
    project = TermGeneration::TaxonomyProjectBuilder.build(name: taxonomy_project_params[:name], csv_url: taxonomy_project_params[:csv_url])
    redirect_to taxonomy_project_path(project)
  end

  def next
    project = TaxonomyProject.find(params[:id])

    next_item = project.next_todo

    if next_item
      redirect_to next_item
    else
      redirect_to project, notice: "All done!"
    end
  end

private

  def taxonomy_project_params
    params.permit(:name, :csv_url)
  end
end

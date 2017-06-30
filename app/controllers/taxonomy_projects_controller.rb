class TaxonomyProjectsController < ApplicationController
  def index
    @projects = TaxonomyProject.all
  end

  def show
    @project = TaxonomyProject.find(params[:id])
  end

  def new
    @form = NewTaxonomyProject.new
  end

  def create
    form = NewTaxonomyProject.new(taxonomy_project_params)
    form.save
    redirect_to taxonomy_project_path(form.project_id)
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
    params.require(:new_taxonomy_project).permit(:name, :csv_url)
  end
end

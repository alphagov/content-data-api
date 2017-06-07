class TaxonomyProjectsController < ApplicationController
  def index
    @projects = TaxonomyProject.all
  end

  def show
    @project = TaxonomyProject.find(params[:id])
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
end

class TaxonomyProjectsController < ApplicationController
  def index
    @projects = TaxonomyProject.all
  end

  def show
    @project = TaxonomyProject.find(params[:id])
  end
end

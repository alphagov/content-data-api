class TaxonomyTodosController < ApplicationController
  def redirect_to_first
    taxonomy_project = TaxonomyProject.find(params[:taxonomy_project_id])
    redirect_to taxonomy_project.taxonomy_todos.still_todo.first
  end

  def show
    taxonomy_todo = TaxonomyTodo.find(params[:id])
    @todo_form = TaxonomyTodoForm.new(taxonomy_todo: taxonomy_todo)
  end

  def update
    taxonomy_todo = TaxonomyTodo.find(params[:id])
    todo_form = TaxonomyTodoForm.new(todo_params)
    todo_form.taxonomy_todo = taxonomy_todo
    todo_form.user = current_user
    todo_form.save

    next_item = taxonomy_todo.taxonomy_project.taxonomy_todos.still_todo.first

    if next_item
      redirect_to next_item
    else
      redirect_to taxonomy_todo.taxonomy_project, notice: "All done!"
    end
  end

private

  def todo_params
    params.require(:taxonomy_todo_form).permit(:new_terms)
  end
end

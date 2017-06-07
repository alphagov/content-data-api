class TaxonomyTodosController < ApplicationController
  def show
    @todo_form = TaxonomyTodoForm.new(taxonomy_todo: taxonomy_todo)
  end

  def update
    todo_form = TaxonomyTodoForm.new(todo_params)
    todo_form.taxonomy_todo = taxonomy_todo
    todo_form.user = current_user
    todo_form.save

    redirect_to next_taxonomy_project_path(taxonomy_todo.taxonomy_project)
  end

private

  def taxonomy_todo
    @taxonomy_todo ||= TaxonomyTodo.find(params[:id])
  end

  def todo_params
    params.require(:taxonomy_todo_form).permit(:new_terms)
  end
end

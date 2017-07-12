class TaxonomyTodosController < ApplicationController
  def show
    @todo_form = TaxonomyTodoForm.new(
      taxonomy_todo: taxonomy_todo,
      terms: taxonomy_todo.terms.order(:name).pluck(:name).join(','),
    )
  end

  def update
    todo_form = TaxonomyTodoForm.new(todo_params)
    todo_form.taxonomy_todo = taxonomy_todo
    todo_form.user = current_user
    todo_form.save

    redirect_to_next_item
  end

  def dont_know
    taxonomy_todo.change_state!(TaxonomyTodo::STATE_DONT_KNOW, current_user)

    redirect_to_next_item
  end

  def not_relevant
    taxonomy_todo.change_state!(TaxonomyTodo::STATE_NOT_RELEVANT, current_user)

    redirect_to_next_item
  end

private

  def redirect_to_next_item
    redirect_to next_taxonomy_project_path(taxonomy_todo.taxonomy_project)
  end

  def taxonomy_todo
    @taxonomy_todo ||= TaxonomyTodo.find(params[:id])
  end

  def todo_params
    params.require(:taxonomy_todo_form).permit(:terms)
  end
end

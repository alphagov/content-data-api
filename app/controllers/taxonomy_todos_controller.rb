class TaxonomyTodosController < ApplicationController
  def show
    @todo_form = TaxonomyTodoForm.new(taxonomy_todo: taxonomy_todo)
  end

  def update
    todo_form = TaxonomyTodoForm.new(todo_params)
    todo_form.taxonomy_todo = taxonomy_todo
    todo_form.user = current_user
    todo_form.save

    redirect_to_next_item
  end

  def dont_know
    taxonomy_todo.update!(
      status: TaxonomyTodo::STATE_DONT_KNOW,
      completed_at: Time.zone.now,
      completed_by: current_user.uid
    )

    redirect_to_next_item
  end

  def not_relevant
    taxonomy_todo.update!(
      status: TaxonomyTodo::STATE_NOT_RELEVANT,
      completed_at: Time.zone.now,
      completed_by: current_user.uid
    )

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
    params.require(:taxonomy_todo_form).permit(:new_terms)
  end
end

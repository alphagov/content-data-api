class TaxonomyTodosController < ApplicationController
  def show
    @todo_form = TaxonomyTodoForm.new(taxonomy_todo: taxonomy_todo)
    if flash.key?(:taxonomy_todos_params)
      @todo_form.terms = flash[:taxonomy_todos_params][:terms]
      @todo_form.valid?
    else
      @todo_form.terms = taxonomy_todo.terms.order(:name).pluck(:name).join(',')
    end
  end

  def update
    @todo_form = TaxonomyTodoForm.new(todo_params)
    @todo_form.taxonomy_todo = taxonomy_todo
    @todo_form.user = current_user
    if @todo_form.valid?
      @todo_form.save
      redirect_to_next_item
    else
      flash.alert = @todo_form.errors.full_messages.join(', ')
      flash[:taxonomy_todos_params] = todo_params
      redirect_to taxonomy_todo
    end
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

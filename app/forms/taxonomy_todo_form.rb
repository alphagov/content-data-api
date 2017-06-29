class TaxonomyTodoForm
  include ActiveModel::Model
  attr_accessor :taxonomy_todo, :terms, :user

  delegate :title, :url, :description, to: :content_item

  def save
    TaxonomyTodo.transaction do
      update_todo
      save_terms
    end
  end

  def content_item
    taxonomy_todo.content_item.decorate
  end

  def project
    taxonomy_todo.taxonomy_project
  end

private

  def update_todo
    taxonomy_todo.change_state!(TaxonomyTodo::STATE_TAGGED, user)
  end

  def save_terms
    taxonomy_todo.terms =
      terms
        .split(',')
        .map(&:squish)
        .map { |term| taxonomy_todo.taxonomy_project.terms.where(name: term) }
        .map(&:first_or_create!)
  end
end

class TaxonomyTodoForm
  include ActiveModel::Model
  attr_accessor :taxonomy_todo, :new_terms, :user

  def save
    TaxonomyTodo.transaction do
      update_todo
      save_terms
    end
  end

  def content_item
    taxonomy_todo.content_item.decorate
  end

private

  def update_todo
    taxonomy_todo.update!(
      completed_at: Time.zone.now,
      completed_by: user.uid
    )
  end

  def save_terms
    split_terms = new_terms.split(',').map(&:strip)

    split_terms.each do |term_text|
      term = Term.find_or_create_by!(
        name: term_text,
        taxonomy_project: taxonomy_todo.taxonomy_project
      )

      taxonomy_todo.content_item.terms << term
    end
  end
end

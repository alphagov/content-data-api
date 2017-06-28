module Taxonomy
  class ProjectStats
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def todo_count
      @todo_count ||= scope.taxonomy_todos.count
    end

    def done_count
      @done_count ||= scope.taxonomy_todos.done.count
    end

    def still_todo_count
      @still_todo_count ||= scope.taxonomy_todos.still_todo.count
    end

    def progress_percentage
      (done_count / todo_count.to_f) * 100
    end
  end
end

module TermGeneration
  module RateOfDiscovery
    WINDOW_SIZE = 50

    # Calculate the moving-window average of the absolute change
    # in new term discovery for a project. Aims to give insight
    # into the expected reward of reviewing a single extra page.

    def self.calculate(project)
      results = []

      # Keeps track of previously seen unique terms.
      terms = Set.new

      # Iterate over previously completed Todos in completion order.
      project_todos(project).each do |todo|
        # Note how many terms have been encountered thus far.
        count_of_previously_found_terms = terms.size

        # Add the terms from this Todo to the set of all terms.
        terms.merge Set.new(todo.terms)

        # Record the absolute change in number of terms encountered for this Todo.
        results << {
          count_of_new_terms: terms.size - count_of_previously_found_terms
        }

        # Our window is the last 50 results.
        moving_window = results.last(WINDOW_SIZE)

        # Calculate the absolute change in terms found over the course of the window.
        total_change = moving_window.sum { |r| r[:count_of_new_terms] }

        # Average the result. Expected values are roughly between 0.3 and 1.5
        results[-1][:moving_average] = total_change.to_f / moving_window.size
      end

      # Return an array of floating point values.
      results.map { |r| r[:moving_average] }
    end

    def self.project_todos(project)
      project.taxonomy_todos.done.order(completed_at: :asc).includes(:terms)
    end
  end
end

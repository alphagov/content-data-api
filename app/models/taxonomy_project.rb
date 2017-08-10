# A Taxonomy Project is part of the process to create a new branch of the
# single-subject term_generation.
#
# The goal of the process is to generate a set of terms that describe the
# content. The terms will then be cleaned, merged and grouped. They'll form the
# basis of the new term_generation branch after user research. A project has many
# "todos", which are pages content designers have to generate terms for. The
# todos will be created by a import script.
class TaxonomyProject < ApplicationRecord
  has_many :taxonomy_todos
  has_many :terms

  def next_todo
    taxonomy_todos.still_todo.order('RANDOM()').limit(1).first
  end

  def stats
    TermGeneration::ProjectStats.new(self)
  end
end

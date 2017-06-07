# A Taxonomy Project is part of the process to create a new branch of the
# single-subject taxonomy.
#
# The goal of the process is to generate a set of terms that describe the
# content. The terms will then be cleaned, merged and grouped. They'll form the
# basis of the new taxonomy branch after user research. A project has many
# "todos", which are pages content designers have to generate terms for. The
# todos will be created by a import script.
class TaxonomyProject < ApplicationRecord
  has_many :taxonomy_todos
  has_many :terms
end

class Question < ApplicationRecord
  validates :text, presence: true

  def initialize(*)
    fail NotImplementedError, "Abstract class" if self.class == Question
    super
  end

  def to_partial_path
    "audits/#{type.underscore}"
  end
end

class BooleanQuestion < Question
  PASS = "yes".freeze
end

class FreeTextQuestion < Question
end

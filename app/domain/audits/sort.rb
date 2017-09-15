module Audits
  class Sort
    attr_reader :combined, :column, :direction

    def self.column(combined)
      Sort.new(combined).column
    end

    def self.direction(combined)
      Sort.new(combined).direction
    end

    def self.combine(column, direction)
      return unless column.present? && direction.present?
      raise(ArgumentError, "Invalid sort direction: #{direction}") unless direction.to_s =~ /asc|desc/

      "#{column}_#{direction}"
    end

    def initialize(combined)
      return unless combined.present?
      raise(ArgumentError, "Invalid value: #{combined}") unless combined =~ /\A[a-z]+_(asc|desc)\z/

      @combined = combined
      values = combined.split("_")
      @column = values[0]
      @direction = values[1]
    end
  end
end

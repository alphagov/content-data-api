module Content
  class MetricCalculator
    def initialize(content_item)
      @content_item = content_item
    end

    def title_length
      @title_length ||= @content_item[:title].length
    end

    def reading_grade
      body_analysis["score"]
    end

    def word_count
      body_analysis["word_count"]
    end

    def updated_at
      @content_item[:updated_at]
    end

    def phase
      @content_item[:phase]
    end

    def publication_state
      @content_item[:publication_state]
    end

    def version_number
      @content_item[:user_facing_version]
    end

    def to_h
      {
        title_length: title_length,
        reading_grade: reading_grade,
        word_count: word_count,
        last_updated_at: updated_at,
        phase: phase,
        publication_state: publication_state,
        version_number: version_number,
      }
    end

  private

    def body_analysis
      @body_analysis ||= Odyssey.smog(body_plain_text, true)
    end

    def body_plain_text
      @plain_text ||= Govspeak::Document.new(combined_body).to_text
    end

    def combined_body
      return "" unless @content_item.dig(:details, :parts).present?

      @content_item[:details][:parts]
        .map { |part| combined_part(part) }
        .join("\n")
    end

    def combined_part(part)
      return "" unless part[:body].present?

      # We're assuming that all guides are written in govspeak - check this assumption here
      part[:body].each { |body_fragment| raise unless body_fragment[:content_type] == "text/govspeak" }

      part[:body]
        .map { |body_fragment| body_fragment[:content] }
        .join("\n")
    end
  end
end

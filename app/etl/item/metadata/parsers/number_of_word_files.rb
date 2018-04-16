module Item::Metadata::Parsers
  class NumberOfWordFiles
    def self.parse(raw_json)
      extensions = %w(doc docx docm)

      { number_of_word_files: NumberOfFiles.number_of_files(raw_json, extensions) }
    end
  end
end

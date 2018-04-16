module Content
  class Parsers::Metadata::NumberOfWordFiles
    def self.parse(raw_json)
      extensions = %w(doc docx docm)

      { number_of_word_files: Parsers::Metadata::NumberOfFiles.number_of_files(raw_json, extensions) }
    end
  end
end

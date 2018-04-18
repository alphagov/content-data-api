module Item::Metadata::Parsers
  class NumberOfPdfs
    def self.parse(raw_json)
      extensions = %w(pdf)

      { number_of_pdfs: NumberOfFiles.number_of_files(raw_json, extensions) }
    end
  end
end

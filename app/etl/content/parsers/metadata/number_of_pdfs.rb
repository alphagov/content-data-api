module Content
  class Parsers::Metadata::NumberOfPdfs
    def self.parse(raw_json)
      extensions = %w(pdf)

      { number_of_pdfs: Parsers::Metadata::NumberOfFiles.number_of_files(raw_json, extensions) }
    end
  end
end

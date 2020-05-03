module Etl::Edition::Metadata
  class NumberOfPdfs
    def self.parse(raw_json)
      NumberOfFiles.number_of_files(raw_json, %w[pdf])
    end
  end
end

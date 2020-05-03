module Etl::Edition::Metadata
  class NumberOfWordFiles
    def self.parse(raw_json)
      NumberOfFiles.number_of_files(raw_json, %w[doc docx docm])
    end
  end
end

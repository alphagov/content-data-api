module Audits
  RSpec.describe Sort do
    context "Splitting a combined sort string" do
      it "splits the string for descending" do
        sort = Sort.new("title_desc")

        expect(sort.column).to eq("title")
        expect(sort.direction).to eq("desc")
      end

      it "splits the string for ascending" do
        sort = Sort.new("title_asc")

        expect(sort.column).to eq("title")
        expect(sort.direction).to eq("asc")
      end

      it "raises if the string is not the correct format" do
        expect { Sort.new("title_foo") }.to raise_error(ArgumentError)
      end

      it "has empty values for an empty string" do
        sort = Sort.new("")

        expect(sort.column).to be_nil
        expect(sort.direction).to be_nil
      end
    end

    context "Combining a sort string" do
      it "combines a column and direction" do
        combined = Sort.combine("title", "asc")

        expect(combined).to eq("title_asc")
      end

      it "does not combine invalid directions" do
        expect { Sort.combine("title", "foo") }.to raise_error(ArgumentError)
      end
    end
  end
end

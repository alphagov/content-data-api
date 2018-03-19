module Performance
  RSpec.describe Metrics::NumberOfWordFiles do
    subject { Metrics::NumberOfWordFiles }

    describe "#parse" do
      it "returns the number of word files present" do
        details = {
          'documents' => '<div class=\"attachment-details\">\n<a href=\"link.doc\">1</a>\n\n\n\n</div>'
        }

        expect(subject.parse('details' => details)).to eq(number_of_word_files: 1)
      end

      it "returns 0 if no word files are present" do
        details = {
          'documents' => '<div class=\"attachment-details\">\n<a href=\"link.txt\">1</a>\n\n\n\n</div>'
        }

        expect(subject.parse('details' => details)).to eq(number_of_word_files: 0)
      end

      it "returns 0 if no document keys are present" do
        expect(subject.parse('details' => {})).to eq(number_of_word_files: 0)
      end

      it "returns 0 if the details is nil" do
        expect(subject.parse({})).to eq(number_of_word_files: 0)
      end
    end
  end
end

require 'gds_api/test_helpers/content_store'
RSpec.describe Content::Parsers::Metadata::NumberOfWordFiles do
  include GdsApi::TestHelpers::ContentStore

  subject { described_class }

  it "returns the number of '.doc' word files present" do
    response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.doc\">1</a>\n\n\n\n</div>')
    expect(subject.parse(response)).to eq(number_of_word_files: 1)
  end

  it "returns the number of '.docm' word files present" do
    response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.docm\">1</a>\n\n\n\n</div>')
    expect(subject.parse(response)).to eq(number_of_word_files: 1)
  end

  it "returns the number of '.docx' word files present" do
    response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>')
    expect(subject.parse(response)).to eq(number_of_word_files: 1)
  end

  it "returns 0 if no word files are present" do
    response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.txt\">1</a>\n\n\n\n</div>')
    expect(subject.parse(response)).to eq(number_of_word_files: 0)
  end

  it "returns 0 if no document keys are present" do
    expect(subject.parse(build_response({}))).to eq(number_of_word_files: 0)
  end

  it "returns 0 if the details is nil" do
    expect(subject.parse(build_response(nil))).to eq(number_of_word_files: 0)
  end

  it "returns 0 if the attachment ends with `doc`, but with no `dot`" do
    response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"linkdoc\">1</a>\n\n\n\n</div>')
    expect(subject.parse(response)).to eq(number_of_word_files: 0)
  end

  it "returns 0 if the attachment file extension starts with '.doc', but ends in 'n' " do
    response = build_response('documents' => '<div class=\"attachment-details\">\n<a href=\"link.docn\">1</a>\n\n\n\n</div>')
    expect(subject.parse(response)).to eq(number_of_word_files: 0)
  end

  def build_response(details)
    content_item_for_base_path('/a-base-path').merge('details' => details)
  end
end

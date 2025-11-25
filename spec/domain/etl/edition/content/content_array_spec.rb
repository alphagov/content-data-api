RSpec.describe Etl::Edition::Content::Parsers::ContentArray do
  it "skips blank content" do
    content = ""
    result = described_class.new.parse(content)
    expect(result).to be_nil
  end

  it "returns content provided as string" do
    content = "Some string"
    result = described_class.new.parse(content)
    expect(result).to eq(content)
  end

  it "returns HTML content when provided with an array" do
    content = [
      {
        "content_type" => "text/govspeak",
        "content" => "## Wrong body",
      },
      {
        "content_type" => "text/html",
        "content" => "<h2>Body</h2>",
        "rendered_by" => "publishing-api",
        "govspeak_version" => "0.0.1",
      },
    ]
    result = described_class.new.parse(content)
    expect(result).to eq("<h2>Body</h2>")
  end
end

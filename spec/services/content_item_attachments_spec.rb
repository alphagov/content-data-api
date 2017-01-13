require 'rails_helper'

RSpec.describe ContentItemAttachments do
  subject { ContentItemAttachments }

  let(:fragment_with_pdfs) {
    '<div class=\"attachment-details\">\n
    <a href=\"link.pdf\">1</a>\n\n\n\n</div>'
  }

  let(:fragment_without_pdfs) {
    '<div class=\"attachment-details\">\n
    <a href=\"link.txt\">1</a>\n\n\n\n</div>'
  }

  it "returns true is pdfs are present" do
    expect(subject.pdfs?(fragment_with_pdfs)).to be(true)
  end

  it "returns false if pdfs are not present" do
    expect(subject.pdfs?(fragment_without_pdfs)).to be(false)
  end
end

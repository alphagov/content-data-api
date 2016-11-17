require 'rails_helper'

describe ContentItem do
  let(:content_item) do
    build(:content_item, organisation_id: 1)
  end

  subject { content_item }

  it "has a content_id attribute" do
    expect(subject.content_id).to eq("fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-1")
  end

  it "belongs to an organisation" do
    expect(subject).to belong_to(:organisation)
  end
end

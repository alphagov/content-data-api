require 'rails_helper'

describe Organisation do
  let(:content_items) do
    [
      build(:content_item, organisation_id: 1)
    ]
  end
  let(:organisation) do
    build(:organisation, slug: "organisation-slug", content_items: content_items)
  end

  subject { organisation }

  it "has a content_id attribute" do
    expect(subject.content_id).to eq("fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-2")
  end


  it "has slug attribute" do
    expect(subject.slug).to eq("organisation-slug")
  end

  it "has number of pages attribute" do
    expect(subject.number_of_pages).to eq(3)
  end

  it "has content items" do
    expect(subject).to have_many(:content_items)
  end

  context "import from Search API" do
    it "imports organisations details" do
      VCR.use_cassette("import_organisations", record: :new_episodes) do
        Organisation.import
      end
      organisation = Organisation.first.as_json
      expect(organisation).to have_key("content_id")
      expect(organisation).to have_key("slug")
      expect(organisation).to have_key("number_of_pages")
    end
  end
end

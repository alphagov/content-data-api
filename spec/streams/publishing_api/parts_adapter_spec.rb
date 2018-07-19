RSpec.describe PublishingAPI::PartsAdapter do
  subject { described_class }

  context ".parts" do
    let(:parts) { subject.new(build(:message, :with_parts)).parts }

    it "returns parts for multipart content" do
      expect(parts.size).to eq(4)
    end

    it "sets the slug to basepath for first part" do
      expect(parts[0]["slug"]).to eq('/base-path')
    end
  end

  context ".title_for" do
    it "returns title for a part" do
      part = {
        "title" => "Title for part",
        "slug" => "/base-path",
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "Summary content"
            }
          ]
        }

        title = subject.new(build(:message, :with_parts)).title_for(part)

      expect(title).to eq("Title for part")
    end
  end

  context ".base_path_for_part" do
    it "returns base path without slug prepended for part at index 0" do
      part_0 = {
        "title" => "Title for part",
        "slug" => "/base-path",
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "Summary content"
            }
          ]
        }

      base_path = subject.new(build(:message, :travel_advice)).base_path_for_part(part_0, 0)

      expect(base_path).to eq("/base-path")
    end

    it "returns base path with slug prepended for part at index 1" do
      part_1 = {
        "title" => "Part 1 title",
        "slug" => "part-1",
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "Content 1"
            }
          ]
        }


      base_path = subject.new(build(:message, :with_parts)).base_path_for_part(part_1, 1)

      expect(base_path).to eq("/base-path/part-1")
    end
  end

  context "Trave Advice" do
    it "returns parts for travel advice with summary as first part" do
      parts = subject.new(build(:message, :travel_advice)).parts

      expect(parts[0]["body"][0]["content"]).to eq("summary content")
    end
  end
end

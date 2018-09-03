RSpec.describe PublishingAPI::Messages::MultipartMessage do
  subject { described_class }

  describe ".is_multipart?" do
    it "returns true if message is for multipart item" do
      expect(subject.is_multipart?(build(:message, :with_parts).payload)).to be(true)
    end

    it "returns false if message is for single part item" do
      expect(subject.is_multipart?(build(:message).payload)).to be(false)
    end
  end

  describe "#parts" do
    let(:parts) { subject.new(build(:message, :with_parts).payload).parts }

    it "returns parts for multipart content" do
      expect(parts.size).to eq(4)
    end

    it "sets the slug to basepath for first part" do
      expect(parts[0]["slug"]).to eq('/base-path')
    end
  end

  context "#title_for" do
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

      title = subject.new(build(:message).payload).title_for(part)

      expect(title).to eq("Title for part")
    end
  end

  context "#base_path_for_part" do
    it "returns base path without slug appended for part at index 0" do
      part_zero = {
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

      base_path = subject.new(build(:message, :with_parts).payload).base_path_for_part(part_zero, 0)

      expect(base_path).to eq("/base-path")
    end

    it "returns base path with slug prepended for part at index 1" do
      part_one = {
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

      base_path = subject.new(build(:message, :with_parts).payload).base_path_for_part(part_one, 1)

      expect(base_path).to eq("/base-path/part-1")
    end
  end

  context "Travel Advice" do
    let(:instance) { subject.new(build(:message, :travel_advice).payload) }

    it "returns base_path for first part" do
      expect(instance.parts[0]["slug"]).to eq("/base-path")
    end

    it "returns parts for travel advice with summary as first part" do
      expect(instance.parts[0]["body"][0]["content"]).to eq("summary content")
    end

    it 'returns the same items with each call' do
      expect(instance.parts.length).to eq(3)
      expect(instance.parts.length).to eq(3)
    end
  end
end

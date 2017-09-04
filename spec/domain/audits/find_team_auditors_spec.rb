module Audits
  RSpec.describe FindTeamAuditors do
    subject { described_class }

    let(:user_uid) { "uid1" }
    let(:organisation_slug) { "slug1" }
    let(:user) { create :user, uid: user_uid, organisation_slug: organisation_slug }

    before do
      create :allocation, user: user
    end

    it "returns only auditors belonging to my organisation" do
      create :user, organisation_slug: :other_org_slug

      expect(subject.call(user_uid: user_uid)).to match_array(user)
    end

    it "returns users ordered by name" do
      user.update name: "BBB"
      user2 = create :user, organisation_slug: organisation_slug, name: "AAA"
      user3 = create :user, organisation_slug: organisation_slug, name: "CCC"

      create :allocation, user: user2
      create :allocation, user: user3

      users = subject.call(user_uid: user_uid)
      expect(users.pluck(:name)).to eq(%w(AAA BBB CCC))
    end

    it "returns only users with content allocated" do
      create :user, organisation_slug: :organisation_slug

      users = subject.call(user_uid: user_uid)
      expect(users).to match_array([user])
    end
  end
end

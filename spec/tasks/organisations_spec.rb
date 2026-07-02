RSpec.describe "rake organisations:*", type: :task do
  before do
    allow($stdout).to receive(:puts)
  end

  describe "check_missing" do
    let(:task) { Rake::Task["organisations:check_missing"] }

    before { task.reenable }

    context "when organisations are missing" do
      it "reports content_ids with no live edition" do
        create :edition,
               content_id: "1390d07f-12b3-4f55-9dd5-fec5fd9e3649",
               live: false

        task.invoke

        expect($stdout).to have_received(:puts)
          .with(/1390d07f.*exists but live=false/)
      end

      it "reports content_ids with no record at all" do
        task.invoke

        expect($stdout).to have_received(:puts)
          .with(/1390d07f.*no record/)
      end
    end

    context "when all organisations are present" do
      before do
        %w[
          1390d07f-12b3-4f55-9dd5-fec5fd9e3649
          63953ed9-98ac-4d08-a1b9-8ea38dbd0832
          99a5828c-79dd-4533-ab18-18069be289cf
        ].each do |content_id|
          create :edition, content_id:, live: true
        end
      end

      it "reports nothing to do" do
        task.invoke

        expect($stdout).to have_received(:puts)
          .with(/All organisations are present/)
      end
    end
  end
end

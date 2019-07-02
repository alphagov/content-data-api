RSpec.describe Healthchecks::DatabaseConnection do
  it { is_expected.to be_enabled }

  its(:name) { is_expected.to eq(:database_status) }

  describe '#status' do
    context 'when the connection is valid' do
      before { Dimensions::Date.create_with(Time.zone.today) }

      its(:status) { is_expected.to eq(:ok) }
      its(:message) { is_expected.to be_blank }
    end

    context 'when the connection is not valid' do
      before { Dimensions::Date.delete_all }

      its(:status) { is_expected.to eq(:critical) }
      its(:message) { is_expected.to eq("Can't connect to Database") }
    end
  end
end

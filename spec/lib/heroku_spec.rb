require 'rails_helper'

RSpec.describe Heroku do
  subject { described_class }

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
  end

  describe '.enabled?' do
    let(:environment) { 'development' }

    context 'in development' do

      it 'returns true if `RUNNING_IN_HEROKU` is present' do
        expect(ENV).to receive(:[]).with("RUNNING_IN_HEROKU").and_return("TRUE")

        expect(described_class.enabled?).to be true
      end
      it 'returns false otherwise' do
        expect(ENV).to receive(:[]).with("RUNNING_IN_HEROKU").and_return(nil)

        expect(described_class.enabled?).to be false
      end
    end

    context 'in production' do
      let(:environment) { 'production' }

      it 'returns false if `RUNNING_IN_HEROKU` is present' do
        expect(ENV).to_not receive(:[]).with("RUNNING_IN_HEROKU")

        expect(described_class.enabled?).to be false
      end
    end
  end
end

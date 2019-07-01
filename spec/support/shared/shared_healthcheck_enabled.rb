RSpec.shared_examples 'Healthcheck enabled/disabled within time range' do
  around do |example|
    @healthcheck_enabled = ENV['ETL_HEALTHCHECK_ENABLED']
    @healthcheck_hour = ENV['ETL_HEALTHCHECK_ENABLED_FROM_HOUR']
    example.run
    ENV['ETL_HEALTHCHECK_ENABLED'] = @healthcheck_enabled
    ENV['ETL_HEALTHCHECK_ENABLED_FROM_HOUR'] = @healthcheck_hour
  end

  describe '#enabled?' do
    let(:today) { Time.zone.new(2018, 1, 15, 16, 0, 0) }

    around do |example|
      Timecop.freeze(today) { example.run }
    end

    context 'when ETL checks are enabled' do
      before do
        ENV['ETL_HEALTHCHECK_ENABLED'] = '1'
        ENV['ETL_HEALTHCHECK_ENABLED_FROM_HOUR'] = '9'
      end

      context 'within time range' do
        let(:today) { Time.zone.new(2018, 1, 15, 9, 1, 0) }

        it { is_expected.to be_enabled }
      end

      context 'out of time range' do
        let(:today) { Time.zone.new(2018, 1, 15, 1, 0, 0) }

        it { is_expected.to_not be_enabled }
      end
    end

    context 'when ETL checks are not enabled' do
      before do
        ENV.delete 'ETL_HEALTHCHECK_ENABLED'
      end

      let(:today) { Time.zone.new(2018, 1, 15, 20, 0, 0) }

      it { is_expected.to_not be_enabled }
    end

    context 'when ETL check is misconfigured' do
      before do
        ENV['ETL_HEALTHCHECK_ENABLED'] = '1'
        ENV['ETL_HEALTHCHECK_ENABLED_FROM_HOUR'] = '9'
      end

      let(:today) { Time.zone.new(2018, 1, 15, 1, 0, 0) }

      it { is_expected.to_not be_enabled }
    end
  end
end

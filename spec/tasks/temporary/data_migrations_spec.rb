RSpec.describe 'rake data_migrations:update_satisfaction', type: task do
  it 'calls Facts::Calculations::SatisfactionScore.apply' do
    create :metric

    calculator = class_double(Facts::Calculations::SatisfactionScore, apply: true).as_stubbed_const

    expect(calculator).to receive(:apply)

    Rake::Task['data_migrations:update_satisfaction'].invoke
  end
end

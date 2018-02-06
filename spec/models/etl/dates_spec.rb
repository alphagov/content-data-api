RSpec.describe ETL::Dates do
  it 'creates yesterdays date when no date exist' do
    ETL::Dates.process

    expect(Dimensions::Date.count).to eq(1)
    expect(Dimensions::Date.first.date).to eq(Date.yesterday)
  end

  it 'does not create duplicates' do
    2.times { ETL::Dates.process }

    expect(Dimensions::Date.count).to eq(1)
  end

  it 'returns the date' do
    result = ETL::Dates.process

    expect(Dimensions::Date.first).to eq(result)
  end
end

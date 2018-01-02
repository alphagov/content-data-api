RSpec.describe ETL::Dates do
  it 'creates current date when no date exist' do
    ETL::Dates.new.process

    expect(Dimensions::Date.count).to eq(1)
    expect(Dimensions::Date.first.date).to eq(Date.today)
  end

  it 'does not create duplicates' do
    2.times { ETL::Dates.new.process }

    expect(Dimensions::Date.count).to eq(1)
  end

  it 'returns the date' do
    result = ETL::Dates.new.process

    expect(Dimensions::Date.first).to eq(result)
  end
end

class AddWithdrawnAndHistoricalConstraints < ActiveRecord::Migration[5.2]
  def up
    say "Updating withdrawn for all editions"
    Dimensions::Edition.update_all(withdrawn: false)

    say "Updating historical for all editions"
    Dimensions::Edition.update_all(historical: false)
  end
end

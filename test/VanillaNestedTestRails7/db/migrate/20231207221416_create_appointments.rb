class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.references :pet
      t.datetime :datetime
      t.timestamps
    end
  end
end

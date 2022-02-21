class CreatePets < ActiveRecord::Migration[6.0]
  def change
    create_table :pets do |t|
      t.references :user
      t.string :name
      t.string :color
    end
  end
end

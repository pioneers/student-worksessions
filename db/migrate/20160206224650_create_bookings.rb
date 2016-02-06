class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.integer :user_id
      t.integer :worksession_id

      t.timestamps null: false
    end
    add_index :bookings, :worksession_id
    add_index :bookings, :user_id
    add_index :bookings, [:worksession_id, :user_id], unique: true
  end
end

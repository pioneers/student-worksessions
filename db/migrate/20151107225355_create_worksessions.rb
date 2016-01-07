class CreateWorksessions < ActiveRecord::Migration
  def change
    create_table :worksessions do |t|
      t.string :created_by
      t.datetime :date
      t.text :notes

      t.timestamps null: false
    end
  end
end

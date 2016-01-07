class AddColumnToWorksessions < ActiveRecord::Migration
  def change
  	add_column :worksessions, :user_id, :integer
  	add_column :worksessions, :begin_at, :datetime
  	add_column :worksessions, :end_at, :datetime
  end
end

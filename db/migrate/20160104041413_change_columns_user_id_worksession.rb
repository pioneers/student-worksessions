class ChangeColumnsUserIdWorksession < ActiveRecord::Migration
  def change
  	change_column :worksessions, :created_by, :integer
  	remove_column :worksessions, :team

  end
end

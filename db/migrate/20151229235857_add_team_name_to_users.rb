class AddTeamNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :team_name, :string
  end
end

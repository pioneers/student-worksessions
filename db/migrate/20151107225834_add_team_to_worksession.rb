class AddTeamToWorksession < ActiveRecord::Migration
  def change
  	add_column :worksessions, :team, :string
  end
end

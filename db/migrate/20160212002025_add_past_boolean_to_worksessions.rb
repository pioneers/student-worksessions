class AddPastBooleanToWorksessions < ActiveRecord::Migration
  def change
    add_column :worksessions, :past, :boolean, default: false
  end
end

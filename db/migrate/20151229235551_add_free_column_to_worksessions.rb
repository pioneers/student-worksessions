class AddFreeColumnToWorksessions < ActiveRecord::Migration
  def change
    add_column :worksessions, :free, :boolean
  end
end

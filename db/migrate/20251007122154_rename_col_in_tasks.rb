class RenameColInTasks < ActiveRecord::Migration[7.1]
  def change
    rename_column :tasks, :contributer_id, :contributor_id
  end
end

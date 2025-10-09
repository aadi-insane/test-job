class ChangeStatusColumnsToStrings < ActiveRecord::Migration[7.1]
  def up
    change_column :tasks, :status, :string, using: 'status::text'
    change_column :projects, :status, :string, using: 'status::text'
  end

  def down
    change_column :tasks, :status, :integer, using: 'status::integer'
    change_column :projects, :status, :integer, using: 'status::integer'
  end
end

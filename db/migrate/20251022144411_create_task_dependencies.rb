class CreateTaskDependencies < ActiveRecord::Migration[7.1]
  def change
    create_table :task_dependencies do |t|
      t.references :task, null: false, foreign_key: { to_table: :tasks }
      t.references :dependent_task, null: false, foreign_key: { to_table: :tasks }

      t.timestamps
    end

    add_index :task_dependencies, [:task_id, :dependent_task_id], unique: true
  end
end

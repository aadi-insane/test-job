class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :description
      t.integer :status, default: 0
      t.references :project, null: false, foreign_key: true
      t.bigint :contributer_id

      t.timestamps
    end
  end
end

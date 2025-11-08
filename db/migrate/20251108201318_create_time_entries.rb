class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ticket_ref
      t.string :task_name
      t.text :notes
      t.string :category
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :duration_seconds

      t.timestamps
    end
  end
end

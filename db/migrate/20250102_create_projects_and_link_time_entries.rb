class CreateProjectsAndLinkTimeEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    add_index :projects, [ :user_id, :name ], unique: true

    add_reference :time_entries, :project, foreign_key: true
  end
end

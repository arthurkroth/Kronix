class AddRoleAndManagerToUsers < ActiveRecord::Migration[7.1]
  def change
    # role: 0 = user, 1 = manager, 2 = admin
    add_column :users, :role, :integer, null: false, default: 0

    # manager_id points to another user (the manager)
    add_column :users, :manager_id, :integer
    add_index  :users, :manager_id
  end
end

class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :userid
      t.string :userpass
      t.integer :count

      t.timestamps
    end
    add_index :members, :userid, unique: true
  end
end

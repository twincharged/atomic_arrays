class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.string  :name
      t.integer :age
      t.text    :hobbies, array: true, default: []
      t.integer :comment_ids, array: true, default: []

      t.timestamps
    end
  end
end
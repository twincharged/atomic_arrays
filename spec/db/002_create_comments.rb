class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, force: true do |t|
      t.integer :user_id
      t.text    :body
      t.text    :tags, array: true, default: []
      t.integer :liker_ids, array: true, default: []

      t.timestamps
    end
  end
end
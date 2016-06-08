class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.integer :visualization_ids, array: true, default: []
      t.integer :story_ids, array: true, default: []
      t.integer :user_ids, array: true, default: []

      t.timestamps null: false
    end
  end
end

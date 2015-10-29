class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.string :type
      t.integer :source_id
      t.integer :target_id
      t.date :from
      t.date :to
      t.date :at

      t.timestamps null: false
    end
  end
end

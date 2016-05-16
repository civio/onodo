class CreateJoinTableChaptersRelations < ActiveRecord::Migration
  def change
    create_join_table :chapters, :relations do |t|
      t.index [:chapter_id, :relation_id], unique: true
    end
  end
end

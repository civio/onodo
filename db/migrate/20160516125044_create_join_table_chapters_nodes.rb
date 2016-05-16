class CreateJoinTableChaptersNodes < ActiveRecord::Migration
  def change
    create_join_table :chapters, :nodes do |t|
      t.index [:chapter_id, :node_id], unique: true
    end
  end
end

class RemoveAtFromRelations < ActiveRecord::Migration
  def up
    Relation.find_each do |r|
      next if exists_interval_for? r
      r[:from] = r[:at]
      r[:to] = r[:at]
      r.save
    end
    remove_column :relations, :at, :date
  end

  def down
    add_column :relations, :at, :date
    Relation.find_each do |r|
      next if exists_interval_for? r
      r[:at] = r[:from]
      r[:from] = nil
      r[:to] = nil
      r.save
    end
  end

  private

  def exists_interval_for? relation
    relation[:from] != relation[:to]
  end
end

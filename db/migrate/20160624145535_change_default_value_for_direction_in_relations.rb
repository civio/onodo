class ChangeDefaultValueForDirectionInRelations < ActiveRecord::Migration
  def up
    change_column_default :relations, :direction, false
  end

  def down
    change_column_default :relations, :direction, true
  end
end

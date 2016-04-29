class AddDefaultValueForVisibleToNodes < ActiveRecord::Migration
	def up
		change_column_default :nodes, :visible, true
	end

	def down
		change_column_default :nodes, :visible, nil
	end
end

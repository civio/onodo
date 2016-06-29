class UpdateDefaultValuesForParametersInVisualizations < ActiveRecord::Migration
  def up
    Visualization.where.not(parameters: nil).find_each do |v|
      params = JSON.parse(v.parameters)
      params['linkDistance'] = 100 if params.keys.include?('linkDistance')
      params['linkStrength'] = -30 if params.keys.include?('linkStrength')
      v.update_attribute(:parameters, params.to_json)
    end
  end
end

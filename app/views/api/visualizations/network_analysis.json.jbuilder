json.visualization @dataset.visualization.as_json
json.visualization do
  json.dataset_id @dataset.id
  json.node_custom_fields @dataset.node_custom_fields
  json.relation_custom_fields @dataset.relation_custom_fields
end
json.nodes @dataset.nodes, partial: 'api/nodes/node', as: :node
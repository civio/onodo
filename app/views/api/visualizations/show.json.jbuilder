json.ignore_nil!
json.extract! @visualization, :id, :parameters
json.dataset_id @dataset.id
json.node_custom_fields @dataset.node_custom_fields
json.relation_custom_fields @dataset.relation_custom_fields
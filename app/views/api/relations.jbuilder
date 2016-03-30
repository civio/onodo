json.array!(@relations) do |relation|
  json.extract! relation, :id, :relation_type, :source_id, :target_id, :from, :to, :at, :created_at, :updated_at, :dataset_id
  json.source_name relation.source.name
  json.target_name relation.target.name
end
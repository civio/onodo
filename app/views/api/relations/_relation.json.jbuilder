json.ignore_nil!

fields = relation.attributes.keys.map(&:to_sym) - [:custom_fields] - [:created_at] - [:updated_at] - [:dataset_id]

json.extract! relation, *fields

if relation.source
  json.source_name relation.source.name
end

if relation.target
  json.target_name relation.target.name
end

json.date format_date_for(relation)

if relation[:custom_fields]
  json.merge! relation.custom_fields
end
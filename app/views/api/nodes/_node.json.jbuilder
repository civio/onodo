json.ignore_nil!

fields = node.attributes.keys.map(&:to_sym) - [:custom_fields] - [:created_at] - [:updated_at] - [:dataset_id] - [:image]

json.extract! node, *fields

if node.image.url
	json.image node.image
end

if node[:custom_fields]
  json.merge! node.custom_fields
end

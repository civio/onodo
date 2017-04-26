json.ignore_nil!

fields = chapter.attributes.keys.map(&:to_sym) - [:story_id] - [:created_at] - [:updated_at] - [:image]

json.extract! chapter, *fields

if chapter.image.url
	json.image chapter.image
end

json.node_ids chapter.nodes.pluck :id
json.relation_ids chapter.relations.pluck :id
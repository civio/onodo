json.merge! chapter.as_json
json.node_ids chapter.nodes.pluck :id
json.relation_ids chapter.relations.pluck :id

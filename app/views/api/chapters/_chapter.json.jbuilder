json.merge! chapter.as_json
json.nodes chapter.nodes, partial: '/api/nodes/node', as: :node
json.relations chapter.relations, partial: '/api/relations/relation', as: :relation
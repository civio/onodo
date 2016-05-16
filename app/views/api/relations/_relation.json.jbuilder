json.merge! relation.as_json
if relation.source
  json.source_name relation.source.name
end
if relation.target
  json.target_name relation.target.name
end
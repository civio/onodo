json.merge! @node.as_json

if @node[:image].nil?
  json.image nil
end
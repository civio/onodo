fields = node.attributes.keys.map(&:to_sym) - [:custom_fields]

json.extract! node, *fields

if node[:image].nil?
  json.image nil
end

if node[:custom_fields]
  json.merge! node[:custom_fields]
end

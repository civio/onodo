fields = relation.attributes.keys.map(&:to_sym) - [:at, :from, :to]

json.extract! relation, *fields

if relation.source
  json.source_name relation.source.name
end
if relation.target
  json.target_name relation.target.name
end

json.date format_date_for(relation)
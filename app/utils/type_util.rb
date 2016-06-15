module TypeUtil
  def type_for(array)
    return "boolean" if boolean?(array)
    return "number"  if number?(array)
    return "string"
  end

  def boolean?(array)
    array.reject{ |e| e.nil? || e.empty? }
        .all?{ |e| e =~ /^(true|verdadero|t|v|yes|s[ií]|y|s|1)$|^(false|falso|f|no|n|0)$/i }
  end

  def cast_to_boolean(value)
    return false if value.nil? || !value || value =~ /^(false|falso|f|no|n|0)$/i
    true
  end

  def number?(array)
    array.reject{ |e| e.nil? || e.empty? }
        .all?{ |e| e == e.to_f.to_s || e == e.to_i.to_s }
  end

  def cast_to_number(value)
    return value.to_i if value.to_i.to_s == value
    value.to_f
  end
end
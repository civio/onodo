module RelationsHelper

  def format_date_for(relation)
    if relation.from == relation.to
      return "#{relation.from}"
    elsif relation.from.nil?
      return "… - #{relation.to}"
    elsif relation.to.nil?
      return "#{relation.from} - …"
    else
      return "#{relation.from} - #{relation.to}"
    end
  end
end

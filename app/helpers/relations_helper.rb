module RelationsHelper

  def format_date_for(relation)
    if relation.to.nil?
      return "#{relation.from}"
    else
      return "#{relation.from} - #{relation.to}"
    end
  end
end

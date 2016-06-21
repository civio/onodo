module RelationsHelper

  def format_date_for(relation)
    return relation.at if relation.transient?
    "#{relation.from || '…'} - #{relation.to || '…'}"
  end
end

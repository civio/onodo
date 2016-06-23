class Relation < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :source, 
              foreign_key: :source_id, 
              class_name: Node, 
              inverse_of: :relations_as_source, 
              touch: true
  belongs_to :target, 
              foreign_key: :target_id, 
              class_name: Node, 
              inverse_of: :relations_as_target, 
              touch: true

  before_validation :ensure_interval_order

  def visualization
    dataset.visualization if dataset
  end

  def stories
    dataset.visualization.stories if dataset && dataset.visualization
  end

  def from
    value = read_attribute(:from)
    value = @at if value.nil? && transient? && (changes_include? :at)
    format value
  end

  def to
    value = read_attribute(:to)
    value = @at if value.nil? && transient? && (changes_include? :at)
    format value
  end

  def at
    from if transient?
  end

  def from=(date)
    return if (invalid_value_for_date? date) || (date.blank? && (changes_include? :at))
    write_attribute(:to, nil) if transient? && !date.blank?
    write_attribute(:from, date)
  end

  def to=(date)
    return if (invalid_value_for_date? date) || (date.blank? && (changes_include? :at))
    write_attribute(:from, nil) if transient? && !date.blank?
    write_attribute(:to, date)
  end

  def at=(date)
    return if (invalid_value_for_date? date) || (changes_include? :from) || (changes_include? :to)
    attribute_will_change! :at
    @at = date
    write_attribute(:from, @at)
    write_attribute(:to, @at)
  end

  def at?
    return true if at
    false
  end

  def transient?
    !interval?
  end

  private

  def ensure_interval_order
    value_from = read_attribute(:from)
    value_to = read_attribute(:to)

    write_attribute(:from, value_to) and write_attribute(:to, value_from) if value_to && value_from && value_to < value_from
  end

  def invalid_value_for_date? date
    return false if date.blank?
    !parse_date date
  end

  def parse_date date
    Date.parse date rescue nil
  end

  def format date
    date.strftime('%d/%m/%Y') rescue nil
  end

  def interval?
    read_attribute(:from) != read_attribute(:to)
  end
end

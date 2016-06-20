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

  def visualization
    dataset.visualization if dataset
  end

  def stories
    dataset.visualization.stories if dataset && dataset.visualization
  end

  def from
    format read_attribute(:from)
  end

  def to
    format read_attribute(:to)
  end

  def at
    format read_attribute(:from) unless interval?
  end

  def from=(date)
    write_attribute(:to, nil) unless interval?
    write_attribute(:from, date)
    ensure_interval
  end

  def to=(date)
    write_attribute(:from, nil) unless interval?
    write_attribute(:to, date)
    ensure_interval
  end

  def at=(date)
    write_attribute(:from, date)
    write_attribute(:to, date)
  end

  def transient?
    !interval?
  end

  private

  def format date
    date.strftime('%d/%m/%Y') if date
  end

  def interval?
    value_from = read_attribute(:from)
    value_to = read_attribute(:to)

    value_from != value_to
  end

  def ensure_interval
    value_from = read_attribute(:from)
    value_to = read_attribute(:to)

    write_attribute(:from, value_to) and write_attribute(:to, value_from) if value_to && value_from && value_to < value_from
  end
end

require 'open3'
require 'csv'

# TODO: This is a poor-man implementation of the interface with the network analysis engine.
# Needs to be replaced with either:
#   - a POST to a network analysis web server. (Simpler, but synchronous.)
#   - a message-based async connection.
class NetworkAnalysis

  def initialize(dataset)
    @relations = dataset.relations
  end

  # Returns a hash with an array of calculated metrics for each node id in the graph,
  # and the list of metrics calculated.
  def calculate_metrics(selected_metrics_list)
    # Check whether there is anything to analyze
    return {}, [] if @relations.empty?

    # Convert the list of selected metrics to the format needed by the network analysis engine
    metrics_shortnames = {
      'clusters' => 'm',
      'degree' => 'd',
      'relevance' => 'r',
      'betweenness' => 'b',
      'closeness' => 'c',
      'coreness' => 'k',
      'distance' => 'l'
    }
    selected_metrics = ''
    selected_metrics_list.each {|m| selected_metrics += metrics_shortnames[m] }

    # Call the engine to calculate the metrics
    results = {}
    column_names = []
    python_filename = Rails.root.join('lib', 'network_analysis', 'network_metrics_onodo.py').to_s
    Open3.popen3('python', python_filename, selected_metrics) do |stdin, stdout, stderr, wait_thread|
      # Send the list of relations to the processor.
      # One line per relation, two node ids separated with a space.
      @relations.each do |relation|
        stdin.puts "#{relation.source_id} #{relation.target_id}"
      end
      stdin.close

      # Read and parse the output.
      # Note we're ignoring the error output for now.
      stdout.each do |line|
        values = CSV.parse_line(line.strip)
        next if values.nil? # Ignore empty lines
        if column_names.empty?
          column_names = values
        else
          values_as_dictionary = {}
          column_names.each_with_index {|column, i| values_as_dictionary[column] = values[i] }
          results[values[0]] = values_as_dictionary
        end
      end

      # Output stderr messages
      stderr.each do |line|
        Rails.logger.error "Error: #{line}"
      end
    end

    # The first column is the node id, remove it from the metrics list
    metrics_names = column_names[1..-1] || []

    return results, metrics_names
  end

end
module MetricFu
  
  # = SaikuroAggregator
  #
  # The SaikuroAggregator class is responsible for aggregating the
  # file size and cyclomatic complexity for each file.
  class SaikuroAggregator
    
    # Enhances the current AggregateCollector with Saikuro metrics
    # for a file. The size result represents the sum of lines of code
    # for each class in the file. The complexity result represents the
    # sum of cyclomatic complexity for each class in the file.
    #
    # @param collector AggregateCollector
    #   Collecting parameter that is being analysed for the current report
    # @param metrics YAML
    #   The current report
    def enhance!(collector, metrics)
      return unless metrics[:saikuro]
      metrics[:saikuro][:files].each do |k, v|
        filename = parse_filename(k[:path]) rescue next
        metric_set = collector.at(filename)
        k[:classes].each do |klass|
          next if klass[:class_name].empty?
          metric_set.complexity += klass[:complexity]
          metric_set.size += klass[:lines]
        end
      end
    end
    
    # Parses the filename from the path provided by saikuro, so that
    # it matches the format used on the other aggregators.
    def parse_filename(string)
      string.match(/\/scratch\/saikuro\/(.*)_cyclo\.html$/)[1]
    end
  end
  
end
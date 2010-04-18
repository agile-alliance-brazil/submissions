module MetricFu
  
  # = FlogAggregator
  #
  # The FlogAggregator class is responsible for aggregating the
  # flog results for each file.
  class FlogAggregator
    
    # Enhances the current AggregateCollector with Flog metrics
    # for a file. The results represents the total score for a
    # file, the total number of methods captured by flog in a file, the average
    # flog score for a file, and the highest flog score in the file.
    #
    # @param collector AggregateCollector
    #   Collecting parameter that is being analysed for the current report
    # @param metrics YAML
    #   The current report
    def enhance!(collector, metrics)
      return unless metrics[:flog]
      metrics[:flog][:pages].each do |k, v|
        filename = parse_filename(k[:path])
        metric_set = collector.at(filename)
        metric_set.flog_total = k[:score] 
        metric_set.flog_methods = k[:scanned_methods].length 
        metric_set.flog_average = k[:average_score] 
        metric_set.flog_highest = k[:highest_score] 
      end
    end
    
    # Parses the filename from the path provided by flog, so that
    # it matches the format used on the other aggregators.
    def parse_filename(string)
      string.sub(/^\//, '') #remove leading slash
    end    
  end
  
end
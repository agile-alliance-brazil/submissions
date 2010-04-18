module MetricFu
  
  # = RcovAggregator
  #
  # The RcovAggregator class is responsible for aggregating the
  # code coverage results for each file.
  class RcovAggregator
    
    # Enhances the current AggregateCollector with Rcov metrics
    # for a file. The coverage result represents the percentage of
    # lines covered by tests as reported by Rcov.
    #
    # @param collector AggregateCollector
    #   Collecting parameter that is being analysed for the current report
    # @param metrics YAML
    #   The current report
    def enhance!(collector, metrics)
      return unless metrics[:rcov]
      metrics[:rcov].each_pair do |filename, value|
        next if filename == :global_percent_run
        collector.at(filename).coverage = value[:percent_run]
      end
    end
  end
    
end

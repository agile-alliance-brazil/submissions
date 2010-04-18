module MetricFu
  
  # = ChurnAggregator
  #
  # The ChurnAggregator class is responsible for aggregating the
  # churn results for each file.
  class ChurnAggregator
    
    # Enhances the current AggregateCollector with Churn metrics
    # for a file. The results represents the total number of times a
    # file was modified on source control.
    #
    # @param collector AggregateCollector
    #   Collecting parameter that is being analysed for the current report
    # @param metrics YAML
    #   The current report
    def enhance!(collector, metrics)
      return unless metrics[:churn]
      metrics[:churn][:changes].each do |change|
        next unless in_code_dir?(change[:file_path])
        collector.at(change[:file_path]).churn = change[:times_changed]
      end
    end
    
    def in_code_dir?(file_path)
      MetricFu.code_dirs.include?(File.dirname(file_path).split('/').first) rescue false
    end
  end
  
end
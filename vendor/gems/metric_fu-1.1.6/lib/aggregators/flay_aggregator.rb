module MetricFu
  
  # = FlayAggregator
  #
  # The FlayAggregator class is responsible for aggregating the
  # total duplication mass for each file.
  class FlayAggregator
    
    # Enhances the current AggregateCollector with Flay metrics
    # for a file. The flay result represents the sum of the
    # mass scores for all duplication matches in a file.
    #
    # @param collector AggregateCollector
    #   Collecting parameter that is being analysed for the current report
    # @param metrics YAML
    #   The current report
    def enhance!(collector, metrics)
      return unless metrics[:flay]
      metrics[:flay][:matches].each do |dup_match|
        score = dup_match[:reason].match(/mass.*= (\d+)/)[1].to_i rescue 0
        dup_match[:matches].each do |file|
          collector.at(file[:name]).flay += score
        end
      end
    end
  end
  
end
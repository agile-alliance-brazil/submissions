module MetricFu
  
  # = AggregateCollector
  #
  # This class is responsible for collecting the results from a particular
  # Report while it is being enhanced by each Aggregator. It then provides
  # the collected results as an Array.
  #
  # Acts as a Collecting Parameter for a particular report.
  class AggregateCollector
    attr_reader :date
    
    # Instantiates an AggregateCollector with the date of the report
    # which it will be collecting results from.
    #
    # @param date String
    #   The date when the report was generated (format YYYYMMDD)
    def initialize(date)
      @date = Date.strptime(date, "%Y%m%d")
      @results = {}
    end

    # Provides a MetricFu::Sample for the specified filename. If a
    # sample doesn't exist for that filename, a new one is instatiated
    # and returned.
    #
    # @param filename String
    #   The name of the file that is currently being analysed
    # 
    # @return MetricFu::Sample
    #   A sample that captures metrics for the specified filename
    def at(filename)
      @results[filename] ||= Sample.new(filename, @date)
    end

    # Provides the collected samples after being processed by all
    # Aggregators.
    #
    # @return Array
    #   A list of MetricFu::Sample with aggregated metrics
    def to_a
      @results.values
    end
  end
end
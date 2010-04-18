module MetricFu
  
  # MetricFu.collector memoizes access to a Collector object, that will be
  # used throughout the lifecycle of the MetricFu app.
  def self.collector
    @collector ||= Collector.new
  end
  
  # = Collector
  #
  # The Collector class is responsible for two things:
  #
  # Collecting aggregated metrics for saved, historical reports.
  #
  # Registering and keeping track of the available Aggregators to be
  # used while collecting metrics.
  class Collector
        
    attr_accessor :aggregators
    
    def initialize
      self.aggregators = {}
    end
    
    # Adds an Aggregator based on the graph type provided.
    #
    # @param graph_type String
    #   The type of graph for which an Aggregator will be instantiated
    def add(graph_type)
      aggregator_name = graph_type.to_s.capitalize + "Aggregator"
      self.aggregators[graph_type] = MetricFu.const_get(aggregator_name).new
    end
    
    # Determines whether an Aggregator exists for a given graph type.
    #
    # @param graph_type String
    #   The type of graph
    #
    # @return Boolean
    #   Does an Aggregator for that graph type exist or not?
    def has_aggregate?(graph_type)
      self.aggregators.has_key?(graph_type)
    end

    # For each stored metrics report, run the registered Aggregators and
    # accumulates its results.
    #
    # @return Array
    #   List of collected MetricFu::MetricSet objects
    def collect
      collected_results = []
      MetricFu.each_historical_report do |date, metrics|
        result = AggregateCollector.new(date)
        self.aggregators.each_pair do |type, aggregator|
          aggregator.enhance!(result, metrics)
        end
        collected_results += result.to_a
      end
      collected_results
    end
  end
  
end
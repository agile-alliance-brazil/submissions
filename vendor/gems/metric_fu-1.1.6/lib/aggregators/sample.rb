module MetricFu
  
  # = Sample
  #
  # The Sample class is responsible for aggregating all metrics
  # for a specific file.
  class Sample
    attr_reader :filename, :date
    attr_accessor :size, :coverage, :complexity, :flay, :churn,
                  :flog_total, :flog_methods, :flog_average, :flog_highest
    
    # Instantiates a Sample for a file in a specific report with default
    # values for available metrics.
    #
    # @param filename String
    #   The file for which all metrics will be aggregated
    #
    # @param date Date
    #   The date when the report was generated
    def initialize(filename, date)
      @filename = filename
      @date = date
      @size = 0
      @coverage = 0.0
      @complexity = 0.0
      @flay = 0
      @churn = 0
      @flog_total = 0
      @flog_methods = 0
      @flog_average = 0
      @flog_highest = 0
    end
  end
end
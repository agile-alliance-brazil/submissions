module MetricFu
  
  # Provides an iterator over historical reports, stored in MetricFu.data_directory.
  #
  # @yield date String
  #   The name of the file, representing the date when it ran (Format: YYYYMMDD)
  # @yield metrics YAML
  #   The YAML representation of the report at that date
  def self.each_historical_report(&blk)
    Dir[File.join(MetricFu.data_directory, '*.yml')].sort.each do |metric_file|
      date = metric_file.split('/')[3].split('.')[0]
      metrics = YAML::load(File.open(metric_file))
      
      blk.call(date, metrics)
    end
  end

end
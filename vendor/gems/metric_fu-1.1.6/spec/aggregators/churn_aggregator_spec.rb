require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::ChurnAggregator do
  before(:each) do
    @aggregator = ChurnAggregator.new
    @collector = AggregateCollector.new('20090811')
    MetricFu::Configuration.run {|config| config.code_dirs = ['lib'] }
    @sample_report = <<-EOYML
    :churn: 
      :changes: 
      - :times_changed: 10
        :file_path: config/routes.rb
      - :times_changed: 5
        :file_path: app/controllers/posts_controller.rb
      - :times_changed: 4
        :file_path: app/controllers/application_controller.rb
      - :times_changed: 3
        :file_path: app/models/post.rb
      - :times_changed: 2
        :file_path: config/environment.rb
      - :times_changed: 1
        :file_path: db/schema.rb
      - :times_changed: 1
        :file_path: lib/model.rb
    EOYML
  end
  
  it "should not process if report doesn't contain Churn results" do
    @aggregator.enhance!(@collector, "")
    @collector.to_a.should be_empty
  end

  it "should compute churn for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
  
    @collector.at('lib/model.rb').churn.should == 1
  end
  
  it "should compute churn for files in a Rails app" do
    MetricFu::Configuration.run {|config| config.code_dirs = ['app', 'lib'] }
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
  
    @collector.at('app/controllers/posts_controller.rb').churn.should == 5
    @collector.at('app/controllers/application_controller.rb').churn.should == 4
    @collector.at('app/models/post.rb').churn.should == 3
  end

  it "should not process if file not in a code directory" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))

    @collector.at('config/routes.rb').churn.should == 0
    @collector.at('config/environment.rb').churn.should == 0
    @collector.at('db/schema.rb').churn.should == 0
  end
  
end

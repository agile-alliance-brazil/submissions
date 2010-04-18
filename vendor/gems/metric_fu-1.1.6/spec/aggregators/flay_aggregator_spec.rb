require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::FlayAggregator do
  before(:each) do
    @aggregator = FlayAggregator.new
    @collector = AggregateCollector.new('20090811')
  end
  
  it "should not process if report doesn't contain Flay results" do
    @aggregator.enhance!(@collector, "")
    @collector.to_a.should be_empty
  end
  
  it "should compute the sum of mass for matches on each file" do
    @aggregator.enhance!(@collector, YAML.load(<<-EOYML))
    :flay: 
      :matches: 
      - :reason: 1) Similar code found in :defn (mass = 50)
        :matches: 
        - :line: "4"
          :name: app/controllers/posts_controller.rb
        - :line: "26"
          :name: app/controllers/posts_controller.rb
      - :reason: 2) Similar code found in :block (mass = 46)
        :matches: 
        - :line: "51"
          :name: app/controllers/posts_controller.rb
        - :line: "68"
          :name: app/controllers/posts_controller.rb
      - :reason: 3) Similar code found in :scope (mass = 904)
        :matches: 
        - :line: "109"
          :name: lib/model/strategy.rb
        - :line: "109"
          :name: app/models/strategy.rb
      :total_score: "1000"
    EOYML
    
    @collector.at('app/controllers/posts_controller.rb').flay.should == 192
    @collector.at('lib/model/strategy.rb').flay.should == 904
    @collector.at('app/models/strategy.rb').flay.should == 904
  end
end

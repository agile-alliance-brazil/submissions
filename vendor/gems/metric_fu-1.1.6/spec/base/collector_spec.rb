require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu do
  
  describe "responding to #collector" do
    it "should return an instance of Collector" do
      MetricFu.collector.should be_a(Collector)
    end
  end
end

describe MetricFu::Collector do
  
  before(:each) do
    @collector = MetricFu::Collector.new
  end
  
  describe "responding to #add" do
    it 'should instantiate a metric aggregator and push it to aggregators' do
      @collector.aggregators.should_receive(:[]=).with('rcov', an_instance_of(RcovAggregator))
      @collector.add("rcov")
    end
  end 
  
  describe "responding to #has_aggregate?" do
    it "should return true if aggregator has been added" do
      @collector.should_not have_aggregate(:rcov)
      @collector.add(:rcov)
      @collector.should have_aggregate(:rcov)
    end
  end
  
  describe "responding to #collect" do
    before(:each) do
      MetricFu.stub!(:each_historical_report)
      @metrics = mock('report')
      @rcov_aggregator = mock(RcovAggregator)
      RcovAggregator.stub!(:new).and_return(@rcov_aggregator)
    end
    
    it "should be empty if no aggregators were added" do
      MetricFu.should_receive(:each_historical_report).and_yield('20090811', @metrics)
      
      @collector.collect.should be_empty
    end
    
    it "should run aggregators for each historical report" do
      MetricFu.stub!(:each_historical_report).and_yield('20090811', @metrics).and_yield('20090911', @metrics)
      @collector.add(:rcov)
      
      @rcov_aggregator.should_receive(:enhance!).twice.with(an_instance_of(AggregateCollector), @metrics)
      
      @collector.collect
    end
    
    it "should collect results from each historical report" do
      MetricFu.stub!(:each_historical_report).and_yield('20090811', @metrics).and_yield('20090911', @metrics)
      collector = mock(AggregateCollector)
      AggregateCollector.should_receive(:new).with('20090811').and_return(collector)
      AggregateCollector.should_receive(:new).with('20090911').and_return(collector)
      
      collector.should_receive(:to_a).and_return([1, 2, 3], [4, 5, 6])
      
      @collector.collect.should == [1, 2, 3, 4, 5, 6]
    end
  end
  
end

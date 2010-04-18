require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::AggregateCollector do
  
  describe "instantiation" do
    it "should parse date of aggregate collector" do
      aggregate_collector = AggregateCollector.new('20090811')
      aggregate_collector.date.should == Date.new(2009, 8, 11)
    end
  end

  describe "responding to #at" do
    before(:each) do
      @aggregate_collector = AggregateCollector.new('20090811')
    end
    
    context "existing Sample for filename" do
      before(:each) do
        @sample = @aggregate_collector.at('some/file_name.rb')
      end
      
      it "should return existing Sample" do
        @aggregate_collector.at('some/file_name.rb').should == @sample
      end
    end
    
    context "non-existing Sample for filename" do
      it "should initialize and return a new Sample" do
        new_sample = @aggregate_collector.at('another/file_name.rb')
        new_sample.should be_instance_of(Sample)
        new_sample.filename.should == 'another/file_name.rb'
        new_sample.date.should == @aggregate_collector.date
      end
    end
  end
  
  describe "responding to #to_a" do
    it "should return an Array representation of all its samples" do
      aggregate_collector = AggregateCollector.new('20090811')
      sample1 = aggregate_collector.at('file1.rb')
      sample2 = aggregate_collector.at('file2.rb')
      sample3 = aggregate_collector.at('file3.rb')
      
      aggregate_collector.to_a.should include(sample1, sample2, sample3)
    end
  end
end

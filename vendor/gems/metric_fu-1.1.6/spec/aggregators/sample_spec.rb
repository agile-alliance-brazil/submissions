require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::Sample do
  
  describe "instantiation" do
    it "should store filename" do
      sample = Sample.new('some/file_name.rb', Date.today)
      sample.filename.should == 'some/file_name.rb'
    end
    
    it "should store date of the report" do
      date = Date.new(2008, 8, 11)
      sample = Sample.new('filename.rb', date)
      sample.date.should == date
    end
    
    it "should initialize default values for each metric" do
      sample = Sample.new('some/file_name.rb', Date.today)
      
      sample.size.should == 0
      sample.complexity.should == 0.0
      sample.coverage.should == 0.0
      sample.flay.should == 0
      sample.churn.should == 0
      sample.flog_total.should == 0
      sample.flog_methods.should == 0
      sample.flog_average.should == 0
      sample.flog_highest.should == 0
    end
  end
  
  it "should allow setting values for metrics" do
    sample = Sample.new('some/file_name.rb', Date.today)
    
    sample.size = 3
    sample.size.should == 3

    sample.complexity = 1.5
    sample.complexity.should == 1.5
    
    sample.coverage = 100.0
    sample.coverage.should == 100.0
    
    sample.flay = 23
    sample.flay.should == 23

    sample.churn = 2
    sample.churn.should == 2
    
    sample.flog_total = 42
    sample.flog_total.should == 42

    sample.flog_methods = 77
    sample.flog_methods.should == 77

    sample.flog_average = 20.2
    sample.flog_average.should == 20.2

    sample.flog_highest = 123
    sample.flog_highest.should == 123
  end
  
end

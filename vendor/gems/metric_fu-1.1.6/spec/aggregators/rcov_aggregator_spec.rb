require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::RcovAggregator do
  before(:each) do
    @aggregator = RcovAggregator.new
    @collector = AggregateCollector.new('20090811')
  end
  
  it "should not process if report doesn't contain Rcov results" do
    @aggregator.enhance!(@collector, "")
    @collector.to_a.should be_empty
  end
  
  it "should compute the code coverage of each file" do
    @aggregator.enhance!(@collector, YAML.load(<<-EOYML))
    :rcov: 
      :global_percent_run: 100.0
      app/helpers/posts_helper.rb: 
        :lines: 
        - :content: "   module PostsHelper"
          :was_run: true
        - :content: "   end"
          :was_run: true
        :percent_run: 100
      app/controllers/application_controller.rb: 
        :lines: 
        - :content: "   # Filters added to this controller apply to all controllers in the application."
          :was_run: true
        - :content: "   # Likewise, all the methods added will be available for all controllers."
          :was_run: true
        - :content: "   "
          :was_run: true
        - :content: "   class ApplicationController < ActionController::Base"
          :was_run: true
        - :content: "     helper :all # include all helpers, all the time"
          :was_run: true
        - :content: "     protect_from_forgery # See ActionController::RequestForgeryProtection for details"
          :was_run: false
        - :content: "   "
          :was_run: false
        - :content: "     # Scrub sensitive parameters from your log"
          :was_run: false
        - :content: "     # filter_parameter_logging :password"
          :was_run: false
        - :content: "   end"
          :was_run: false
        :percent_run: 50
      app/models/post.rb: 
        :lines: 
        - :content: "   class Post < ActiveRecord::Base"
          :was_run: true
        - :content: "   end"
          :was_run: true
        :percent_run: 100
      app/helpers/application_helper.rb: 
        :lines: 
        - :content: "   # Methods added to this helper will be available to all templates in the application."
          :was_run: true
        - :content: "   module ApplicationHelper"
          :was_run: true
        - :content: "   end"
          :was_run: true
        :percent_run: 100
    EOYML
    
    @collector.at('app/helpers/posts_helper.rb').coverage.should == 100
    @collector.at('app/controllers/application_controller.rb').coverage.should == 50
    @collector.at('app/models/post.rb').coverage.should == 100
    @collector.at('app/helpers/application_helper.rb').coverage.should == 100
  end
end

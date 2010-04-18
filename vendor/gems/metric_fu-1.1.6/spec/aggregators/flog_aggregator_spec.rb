require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::FlogAggregator do
  before(:each) do
    @aggregator = FlogAggregator.new
    @collector = AggregateCollector.new('20090811')
    @sample_report = <<-EOYML
    :flog: 
      :average: 12.3
      :total: 98.6
      :pages: 
      - :path: /app/controllers/posts_controller.rb
        :highest_score: 27.3
        :average_score: 13.8
        :scanned_methods: 
        - :operators: 
          - :operator: branch
            :score: 8.5
          - :operator: assignment
            :score: 4.0
          - :operator: params
            :score: 3.3
          - :operator: render
            :score: 3.2
          - :operator: html
            :score: 3.0
          - :operator: xml
            :score: 3.0
          - :operator: "[]"
            :score: 2.9
          - :operator: errors
            :score: 1.8
          - :operator: redirect_to
            :score: 1.6
          - :operator: head
            :score: 1.6
          - :operator: flash
            :score: 1.5
          - :operator: update_attributes
            :score: 1.3
          - :operator: respond_to
            :score: 1.2
          - :operator: find
            :score: 1.2
          :name: PostsController#update
          :score: 27.3
        - :operators: 
          - :operator: branch
            :score: 8.5
          - :operator: render
            :score: 4.8
          - :operator: assignment
            :score: 4.0
          - :operator: xml
            :score: 3.0
          - :operator: html
            :score: 3.0
          - :operator: errors
            :score: 1.8
          - :operator: redirect_to
            :score: 1.6
          - :operator: params
            :score: 1.6
          - :operator: flash
            :score: 1.5
          - :operator: "[]"
            :score: 1.4
          - :operator: save
            :score: 1.3
          - :operator: new
            :score: 1.2
          - :operator: respond_to
            :score: 1.2
          :name: PostsController#create
          :score: 24.3
        - :operators: 
          - :operator: branch
            :score: 4.0
          - :operator: assignment
            :score: 2.5
          - :operator: posts_url
            :score: 1.7
          - :operator: params
            :score: 1.6
          - :operator: head
            :score: 1.5
          - :operator: redirect_to
            :score: 1.5
          - :operator: xml
            :score: 1.4
          - :operator: html
            :score: 1.4
          - :operator: "[]"
            :score: 1.4
          - :operator: respond_to
            :score: 1.2
          - :operator: destroy
            :score: 1.2
          - :operator: find
            :score: 1.2
          :name: PostsController#destroy
          :score: 14.9
        - :operators: 
          - :operator: branch
            :score: 2.6
          - :operator: assignment
            :score: 2.5
          - :operator: params
            :score: 1.6
          - :operator: render
            :score: 1.5
          - :operator: xml
            :score: 1.4
          - :operator: html
            :score: 1.4
          - :operator: "[]"
            :score: 1.4
          - :operator: respond_to
            :score: 1.2
          - :operator: find
            :score: 1.2
          :name: PostsController#show
          :score: 10.3
        - :operators: 
          - :operator: branch
            :score: 2.6
          - :operator: assignment
            :score: 2.5
          - :operator: render
            :score: 1.5
          - :operator: html
            :score: 1.4
          - :operator: xml
            :score: 1.4
          - :operator: new
            :score: 1.2
          - :operator: respond_to
            :score: 1.2
          :name: PostsController#new
          :score: 7.6
        - :operators: 
          - :operator: branch
            :score: 2.6
          - :operator: assignment
            :score: 2.5
          - :operator: render
            :score: 1.5
          - :operator: html
            :score: 1.4
          - :operator: xml
            :score: 1.4
          - :operator: all
            :score: 1.2
          - :operator: respond_to
            :score: 1.2
          :name: PostsController#index
          :score: 7.6
        - :operators: 
          - :operator: params
            :score: 1.6
          - :operator: "[]"
            :score: 1.4
          - :operator: assignment
            :score: 1.2
          - :operator: find
            :score: 1.2
          :name: PostsController#edit
          :score: 4.4
        :score: 96.4
      - :path: /app/controllers/application_controller.rb
        :highest_score: 2.2
        :average_score: 2.2
        :scanned_methods: 
        - :operators: 
          - :operator: helper
            :score: 1.1
          - :operator: protect_from_forgery
            :score: 1.1
          :name: ApplicationController#none
          :score: 2.2
        :score: 2.2
    EOYML
  end
  
  it "should not process if report doesn't contain Flog results" do
    @aggregator.enhance!(@collector, "")
    @collector.to_a.should be_empty
  end
  
  it "should parse filename from flog path" do
    @aggregator.parse_filename("/app/controllers/posts_controller.rb").
      should == "app/controllers/posts_controller.rb"
    @aggregator.parse_filename("/app/controllers/crud_controller.rb").
      should == "app/controllers/crud_controller.rb"
    @aggregator.parse_filename("path/already_parsed.rb").should == "path/already_parsed.rb"
  end
  
  it "should compute the total flog for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
    
    @collector.at('app/controllers/posts_controller.rb').flog_total.should == 96.4
    @collector.at('app/controllers/application_controller.rb').flog_total.should == 2.2
  end

  it "should compute the total number of methods captured by flog for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
    
    @collector.at('app/controllers/posts_controller.rb').flog_methods.should == 7
    @collector.at('app/controllers/application_controller.rb').flog_methods.should == 1
  end

  it "should compute the average flog score for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
    
    @collector.at('app/controllers/posts_controller.rb').flog_average.should == 13.8
    @collector.at('app/controllers/application_controller.rb').flog_average.should == 2.2
  end

  it "should compute the highest flog score for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
    
    @collector.at('app/controllers/posts_controller.rb').flog_highest.should == 27.3
    @collector.at('app/controllers/application_controller.rb').flog_highest.should == 2.2
  end
end

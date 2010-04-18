require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::SaikuroAggregator do
  before(:each) do
    @aggregator = SaikuroAggregator.new
    @collector = AggregateCollector.new('20090811')
    @sample_report = <<-EOYML
    :saikuro: 
      :methods: 
      - :name: PostsController#create
        :lines: 13
        :complexity: 7
      - :name: PostsController#update
        :lines: 13
        :complexity: 7
      - :name: PostsController#destroy
        :lines: 8
        :complexity: 4
      - :name: PostsController#show
        :lines: 7
        :complexity: 3
      - :name: PostsController#new
        :lines: 7
        :complexity: 3
      - :name: PostsController#index
        :lines: 7
        :complexity: 3
      - :name: PostsController#edit
        :lines: 2
        :complexity: 1
      :files: 
      - :filename: posts_controller.rb
        :path: tmp/metric_fu/scratch/saikuro/app/controllers/posts_controller.rb_cyclo.html
        :classes: 
        - :methods: 
          - :name: PostsController#create
            :lines: 13
            :complexity: 7
          - :name: PostsController#update
            :lines: 13
            :complexity: 7
          - :name: PostsController#destroy
            :lines: 8
            :complexity: 4
          - :name: PostsController#show
            :lines: 7
            :complexity: 3
          - :name: PostsController#new
            :lines: 7
            :complexity: 3
          - :name: PostsController#index
            :lines: 7
            :complexity: 3
          - :name: PostsController#edit
            :lines: 2
            :complexity: 1
          :class_name: PostsController
          :lines: 84
          :complexity: 28
      - :filename: application_helper.rb
        :path: tmp/metric_fu/scratch/saikuro/app/helpers/application_helper.rb_cyclo.html
        :classes: 
        - :methods: []

          :class_name: ""
          :lines: 1
          :complexity: 0
        - :methods: []

          :class_name: ApplicationHelper
          :lines: 1
          :complexity: 0
      - :filename: posts_helper.rb
        :path: wrong/file/path/posts_helper.rb
        :classes: 
        - :methods: []

          :class_name: PostsHelper
          :lines: 1
          :complexity: 0
      - :filename: post.rb
        :path: tmp/metric_fu/scratch/saikuro/app/models/post.rb_cyclo.html
        :classes: 
        - :methods: []

          :class_name: Post
          :lines: 1
          :complexity: 0
      - :filename: application_controller.rb
        :path: tmp/metric_fu/scratch/saikuro/app/controllers/application_controller.rb_cyclo.html
        :classes: 
        - :methods: []

          :class_name: ""
          :lines: 1
          :complexity: 0
        - :methods: []

          :class_name: ApplicationController
          :lines: 6
          :complexity: 0
      :classes: 
      - :defs: 
        - :name: PostsController#index
          :lines: 7
          :complexity: 3
        - :name: PostsController#show
          :lines: 7
          :complexity: 3
        - :name: PostsController#new
          :lines: 7
          :complexity: 3
        - :name: PostsController#edit
          :lines: 2
          :complexity: 1
        - :name: PostsController#create
          :lines: 13
          :complexity: 7
        - :name: PostsController#update
          :lines: 13
          :complexity: 7
        - :name: PostsController#destroy
          :lines: 8
          :complexity: 4
        :name: PostsController
        :lines: 84
        :complexity: 28
      - :name: PostsHelper
        :lines: 1
        :complexity: 0
      - :name: Post
        :lines: 1
        :complexity: 0
      - :name: ""
        :lines: 1
        :complexity: 0
      - :name: ApplicationHelper
        :lines: 1
        :complexity: 0
      - :name: ""
        :lines: 1
        :complexity: 0
      - :name: ApplicationController
        :lines: 6
        :complexity: 0
    EOYML
  end
  
  it "should not process if report doesn't contain Saikuro results" do
    @aggregator.enhance!(@collector, "")
    @collector.to_a.should be_empty
  end
  
  it "should parse filename from saikuro path" do
    @aggregator.parse_filename("tmp/metric_fu/scratch/saikuro/app/controllers/posts_controller.rb_cyclo.html").
      should == "app/controllers/posts_controller.rb"
    @aggregator.parse_filename("tmp/metric_fu/scratch/saikuro/app/controllers/crud_controller.rb_cyclo.html").
      should == "app/controllers/crud_controller.rb"
    lambda {@aggregator.parse_filename("wrong_path.rb")}.should raise_error
  end
  
  it "should compute the sum of lines of code for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
    
    @collector.at('app/controllers/posts_controller.rb').size.should == 84
    @collector.at('app/helpers/application_helper.rb').size.should == 1
    @collector.at('app/models/post.rb').size.should == 1
    @collector.at('app/controllers/application_controller.rb').size.should == 6
  end

  it "should compute the sum of cyclomatic complexity of classes for each file" do
    @aggregator.enhance!(@collector, YAML.load(@sample_report))
    
    @collector.at('app/controllers/posts_controller.rb').complexity.should == 28
    @collector.at('app/helpers/application_helper.rb').complexity.should == 0
    @collector.at('app/models/post.rb').complexity.should == 0
    @collector.at('app/controllers/application_controller.rb').complexity.should == 0
  end
end

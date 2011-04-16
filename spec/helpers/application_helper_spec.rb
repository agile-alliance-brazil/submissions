require 'spec_helper'

describe ApplicationHelper do
  describe "fix URL" do
    it "should prepend 'http://' if missing" do
      helper.prepend_http('www.dtsato.com').should == 'http://www.dtsato.com'
    end
    
    it "should not change URL if starts with 'http://'" do
      helper.prepend_http('http://dtsato.com').should == 'http://dtsato.com'
    end
    
    it "should ignore case when fixing" do
      helper.prepend_http('HTTP://dtsato.com/some/path-01').should == 'HTTP://dtsato.com/some/path-01'
    end
    
    it "should not prepend on empty string" do
      helper.prepend_http('').should == ''
      helper.prepend_http(nil).should be_nil
      helper.prepend_http('   ').should == '   '
    end
  end
  
  describe "sort link" do
    before(:each) do
      @params = {:controller => :organizer_sessions, :action => :index}
    end
    
    it "should link down if nothing set" do
      helper.sortable_column('test', :id, @params).should == '<a href="/organizer_sessions?column=id&amp;direction=down">test</a>'
    end

    it "should link down if was going up on that column" do
      @params[:column] = 'id'
      @params[:direction] = 'up'
      helper.sortable_column('test', :id, @params).should == '<a href="/organizer_sessions?column=id&amp;direction=down">test</a>'
    end

    it "should link up if was going down on that column" do
      @params[:column] = 'id'
      @params[:direction] = 'down'
      helper.sortable_column('test', :id, @params).should == '<a href="/organizer_sessions?column=id&amp;direction=up">test</a>'
    end

    it "should link down if was going down on another column" do
      @params[:column] = 'author_id'
      @params[:direction] = 'down'
      helper.sortable_column('test', :id, @params).should == '<a href="/organizer_sessions?column=id&amp;direction=down">test</a>'
    end
    
    it "should reset page when sorting is clicked" do
      @params[:column] = 'id'
      @params[:direction] = 'up'
      @params[:page] = 2
      helper.sortable_column('test', :id, @params).should == '<a href="/organizer_sessions?column=id&amp;direction=down">test</a>'
    end
  end
end

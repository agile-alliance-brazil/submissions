
# encoding: UTF-8
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

  describe "gravatar_url" do
    it "should use digest of user's email to generate URL" do
      user = FactoryGirl.build(:user, :email => 'dtsato@dtsato.com')
      helper.gravatar_url(user).should =~ /http:\/\/gravatar.com\/avatar\/9681863a56f1e1ac9562c72b297f6c2d\.png/
    end

    it "should have default size of normal" do
      user = FactoryGirl.build(:user, :email => 'dtsato@dtsato.com')
      helper.gravatar_url(user).should =~ /s=48/
    end

    it "should allow customized sizes" do
      user = FactoryGirl.build(:user, :email => 'dtsato@dtsato.com')
      helper.gravatar_url(user, :size => :mini).should =~ /s=24/
      helper.gravatar_url(user, "size" => :normal).should =~ /s=48/
      helper.gravatar_url(user, :size => "bigger").should =~ /s=150/
    end

    it "should have use default mistery man if gravatar not available" do
      user = FactoryGirl.build(:user, :email => 'dtsato@dtsato.com')
      helper.gravatar_url(user).should =~ /d=mm/
    end

    it "should allow customized default images" do
      user = FactoryGirl.build(:user, :email => 'dtsato@dtsato.com')
      helper.gravatar_url(user, :default => :retro).should =~ /d=retro/
      helper.gravatar_url(user, "default" => :retro).should =~ /d=retro/
      helper.gravatar_url(user, :default => "retro").should =~ /d=retro/
    end
  end

  describe "translated_country" do
    it "should return translated country from code" do
      helper.translated_country(:BR).should == 'Brasil'
      helper.translated_country('US').should == 'Estados Unidos'
      helper.translated_country('fr').should == 'França'
    end
    
    it "should return empty if country is invalid" do
      helper.translated_country('').should be_empty
      helper.translated_country(nil).should be_empty
      helper.translated_country(' ').should be_empty
    end
  end

  describe "translated_state" do
    it "should return translated state from code" do
      helper.translated_state(:SP).should == 'São Paulo'
      helper.translated_state('RJ').should == 'Rio de Janeiro'
    end

    it "should return empty if state is invalid" do
      helper.translated_state('').should be_empty
      helper.translated_state(nil).should be_empty
      helper.translated_state(' ').should be_empty
      helper.translated_state('SS').should be_empty
    end
  end

  describe "present_date" do
    before :each do
      @date = Time.zone.now
      @conference = Conference.new
      helper = mock(helper)
    end

    it "should make date bold if next deadline matches" do
      @conference.expects(:next_deadline).returns([@date, :submissions])
      helper.present_date(@conference, [@date, :submissions]).should == "<strong>#{l(@date)}: #{t('conference.dates.submissions')}</strong>"
    end

    it "should leave date if next deadline doesn't matches" do
      @conference.expects(:next_deadline).returns([@date + 1, :notifications])
      helper.present_date(@conference, [@date, :submissions]).should == "#{l(@date)}: #{t('conference.dates.submissions')}"
    end

    it "should leave date if next deadline is nil" do
      @conference.expects(:next_deadline).returns(nil)
      helper.present_date(@conference, [@date, :submissions]).should == "#{l(@date)}: #{t('conference.dates.submissions')}"
    end
  end
end

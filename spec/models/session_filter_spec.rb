# encoding: UTF-8
require 'spec_helper'

shared_examples_for "ActiveModel" do
  require 'test/unit/assertions'
  require 'active_model/lint'
  include Test::Unit::Assertions
  include ActiveModel::Lint::Tests

  # to_s is to support ruby-1.9
  ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
    example m.gsub('_',' ') do
      send m
    end
  end

  let(:model) { subject }
end

describe SessionFilter do
  it_should_behave_like "ActiveModel"

  describe "filtering by user" do
    context "with param user_id" do
      subject { SessionFilter.new(:user_id => '1') }

      its(:user_id) { should == '1' }

      it "should provide username reader" do
        user = FactoryGirl.build(:user)
        User.expects(:find).with('1').returns(user)

        subject.username.should == user.username
      end
    end

    context "without param user_id" do
      subject { SessionFilter.new }

      its(:user_id) { should be_nil }
      its(:username) { should be_nil }
    end

    context "with param username" do
      subject { SessionFilter.new(:session_filter => {:username => 'dtsato'}) }

      before(:each) do
        @user = FactoryGirl.build(:user, :id => 1)
        User.stubs(:find_by_username).with('dtsato').returns(@user)
      end

      its(:user_id) { should == 1 }
    end

    context "without param username" do
      subject { SessionFilter.new(:session_filter => {}) }

      its(:user_id) { should be_nil }
      its(:username) { should be_nil }
    end

    it "should provide username writer" do
      user = FactoryGirl.build(:user, :id => 1)
      User.expects(:find_by_username).twice.with(user.username).returns(user)

      subject.username = user.username
      subject.user_id.should == 1

      subject.username = "  #{user.username}  "
      subject.user_id.should == 1
    end

    it "username writer should not fail when invalid username" do
      User.expects(:find_by_username).with('dansato').returns(nil)

      subject.username = 'dansato'
      subject.user_id.should be_nil

      subject.username = ""
      subject.user_id.should be_nil
    end
  end

  describe "filtering by tag" do
    context "with param tags" do
      subject { SessionFilter.new(:session_filter => {:tags => 'test, software'}) }

      its(:tags) { should == 'test, software' }
    end

    context "without param tags" do
      subject { SessionFilter.new(:session_filter => {}) }

      its(:tags) { should be_nil }
    end
  end

  describe "filtering by track" do
    context "with param track_id" do
      subject { SessionFilter.new(:session_filter => {:track_id => 8}) }

      its(:track_id) { should == 8 }
    end

    context "without param track_id" do
      subject { SessionFilter.new(:session_filter => {}) }

      its(:track_id) { should be_nil }
    end
  end

  describe "apply scopes" do
    it "should apply user scope when user_id is present" do
      scope = mock('scope')
      scope.expects(:for_user).with(1)

      filter = SessionFilter.new(:user_id => 1)
      filter.apply(scope)
    end

    it "should apply tag scope when tags are present" do
      scope = mock('scope')
      scope.expects(:tagged_with).with('tag1, tag2')

      filter = SessionFilter.new(:session_filter => {:tags => 'tag1, tag2'})
      filter.apply(scope)
    end

    it "should apply track scope when track_id is present" do
      scope = mock('scope')
      scope.expects(:for_tracks).with('1')

      filter = SessionFilter.new(:session_filter => {:track_id => '1'})
      filter.apply(scope)
    end

    it "should combine scopes" do
      scope = mock('scope')
      scope.expects(:tagged_with).with('tag1, tag2').returns(scope)
      scope.expects(:for_tracks).with('1').returns(scope)
      scope.expects(:for_user).with(1).returns(scope)

      filter = SessionFilter.new(:user_id => 1, :session_filter => {:tags => 'tag1, tag2', :track_id => '1'})
      filter.apply(scope)
    end
  end
end
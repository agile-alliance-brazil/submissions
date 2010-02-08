require 'spec/spec_helper'

describe Ability do
  before(:each) do
    @user = Factory.build(:user)
  end
  
  shared_examples_for "all users" do
    it "can read all" do
      @ability.should be_can(:read, :all)
    end
    
    it "can login/logout" do
      @ability.should be_can(:create, UserSession)
      @ability.should be_can(:destroy, UserSession)
    end
    
    it "can create a new account" do
      @ability.should be_can(:create, User)
    end
    
    it "can update their own account" do
      @ability.should be_can(:update, @user)
      @ability.should be_cannot(:update, User.new)
    end

    it "can create comments" do
      @ability.should be_can(:create, Comment)
    end
    
    it "can update their comments" do
      comment = Comment.new
      @ability.should be_cannot(:update, comment)
      comment.user = @user
      @ability.should be_can(:update, comment)
    end

    it "can destroy their comments" do
      comment = Comment.new
      @ability.should be_cannot(:destroy, comment)
      comment.user = @user
      @ability.should be_can(:destroy, comment)
    end
  end

  context "- all users (guests)" do
    before(:each) do
      @ability = Ability.new(@user)
    end

    it_should_behave_like "all users"
  end
  
  context "- admin" do
    before(:each) do
      @user.add_role "admin"
      @ability = Ability.new(@user)
    end

    it "can manage all" do
      @ability.should be_can(:manage, :all)
    end
  end

  context "- author" do
    before(:each) do
      @user.add_role "author"
      @ability = Ability.new(@user)
    end

    it_should_behave_like "all users"
    
    it "can create sessions" do
      @ability.should be_can(:create, Session)
    end
    
    describe "can update session if:" do
      before(:each) do
        @session = Factory(:session)
        Time.zone.stub!(:now).and_return(Time.zone.local(2010, 1, 1))
      end
      
      it "- user is first author" do
        @ability.should be_cannot(:update, @session)
        @session.author = @user
        @ability.should be_can(:update, @session)
      end
      
      it "- user is second author" do
        @ability.should be_cannot(:update, @session)
        @session.second_author = @user
        @ability.should be_can(:update, @session)
      end
      
      it "- before deadline of 28/2/2010" do
        @session.author = @user
        Time.zone.should_receive(:now).and_return(Time.zone.local(2010, 2, 28, 23, 59, 59))
        @ability.should be_can(:update, @session)
      end
      
      it "- after deadline author can't update" do
        @session.author = @user
        Time.zone.should_receive(:now).and_return(Time.zone.local(2010, 3, 1, 0, 0, 0))
        @ability.should be_cannot(:update, @session)
      end
    end
  end
end

require 'spec/spec_helper'

describe Ability do
  before(:each) do
    @user = Factory(:user)
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
    
    it "can edit their comments" do
      comment = Comment.new
      @ability.should be_cannot(:edit, comment)
      comment.user = @user
      @ability.should be_can(:edit, comment)
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
    
    it "can read votes" do
      vote = Vote.new
      @ability.should be_can(:read, vote)
    end
    
    it "cannot update votes" do
      @ability.should be_cannot(:update, Vote)
      vote = Vote.new
      @ability.should be_cannot(:update, vote)
    end
    
    describe "can vote if:" do
      before(:each) do
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
      end
      
      it "- haven't voted yet" do
        @ability.should be_can(:create, Vote)
        Factory(:vote, :user => @user)
        @ability.should be_cannot(:create, Vote)
      end
      
      it "- before deadline of 7/3/2010" do
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 7, 23, 59, 59))
        @ability.should be_can(:create, Vote)
      end
      
      it "- after deadline can't vote" do
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 8, 0, 0, 0))
        @ability.should be_cannot(:create, Vote)
      end
    end

    describe "can change vote if:" do
      before(:each) do
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
        @vote = Factory(:vote, :user => @user)
      end
      
      it "- has already voted" do
        @ability.should be_can(:update, @vote)
      end

      it "- vote belongs to user" do
        another_vote = Factory(:vote)
        @ability.should be_can(:update, @vote)
        @ability.should be_cannot(:update, another_vote)
      end
      
      it "- before deadline of 7/3/2010" do
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 7, 23, 59, 59))
        @ability.should be_can(:update, @vote)
      end
      
      it "- after deadline can't vote" do
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 8, 0, 0, 0))
        @ability.should be_cannot(:update, @vote)
      end
    end
    
    it "can new vote after voting" do
      @ability.should be_can(:new, Vote)
      Factory(:vote, :user => @user)
      @ability.should be_can(:new, Vote)
    end
    
  end

  context "- all users (guests)" do
    before(:each) do
      @ability = Ability.new(@user)
    end

    it_should_behave_like "all users"
    
    describe "can update reviewer if:" do
      before(:each) do
        @reviewer = Factory(:reviewer, :user => @user)
        @reviewer.invite
      end
      
      it "- user is the same" do
        @ability.should be_can(:update, @reviewer)
        @reviewer.user = nil
        @ability.should be_cannot(:update, @reviewer)
      end
      
      it "- reviewer is in invited state" do
        @ability.should be_can(:update, @reviewer)
        @reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
        @reviewer.accept
        @ability.should be_cannot(:update, @reviewer)
      end
    end
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
    
    describe "can create sessions if:" do
      before(:each) do
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
      end
      
      it "- before deadline of 7/3/2010" do
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 7, 23, 59, 59))
        @ability.should be_can(:create, Session)
      end
      
      it "- after deadline author can't update" do
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 8, 0, 0, 0))
        @ability.should be_cannot(:create, Session)
      end
    end
    
    describe "can update session if:" do
      before(:each) do
        @session = Factory(:session)
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
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
      
      it "- before deadline of 7/8/2010" do
        @session.author = @user
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 7, 23, 59, 59))
        @ability.should be_can(:update, @session)
      end
      
      it "- after deadline author can't update" do
        @session.author = @user
        Time.zone.expects(:now).returns(Time.zone.local(2010, 3, 8, 0, 0, 0))
        @ability.should be_cannot(:update, @session)
      end
    end
  end

  context "- organizer" do
    before(:each) do
      @user.add_role "organizer"
      @ability = Ability.new(@user)
    end

    it_should_behave_like "all users"
    
    it "can manage reviewer" do
      @ability.should be_can(:manage, Reviewer)
    end
    
    it "cannot read organizers" do
      @ability.should be_cannot(:read, Organizer)
    end
    
    it "can read sessions to organize" do
      @ability.should be_can(:index, 'organizer_sessions')
    end
    
    context "can cancel session if:" do
      before(:each) do
        @session = Factory(:session)
      end
      
      it "- session on organizer's track" do
        @ability.should be_cannot(:cancel, @session)
        Factory(:organizer, :track => @session.track, :user => @user)
        @ability.should be_can(:cancel, @session)
      end
    end
  end

  context "- reviewer" do
    before(:each) do
      @user.add_role "reviewer"
      @ability = Ability.new(@user)
    end

    it_should_behave_like "all users"
    
    it "cannot read organizers" do
      @ability.should be_cannot(:read, Organizer)
    end

    it "cannot read other reviewers" do
      @ability.should be_cannot(:read, Reviewer)
    end
    
    it "cannot read organizer's sessions" do
      @ability.should be_cannot(:read, 'organizer_sessions')
    end
  end
end

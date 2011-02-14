require 'spec_helper'

describe Ability do
  before(:each) do
    @user = Factory(:user)
    @conference = Factory(:conference)
  end
  
  shared_examples_for "all users" do
    it "can read public entities" do
      @ability.should be_able_to(:read, User)
      @ability.should be_able_to(:read, Session)
      @ability.should be_able_to(:read, Comment)
      @ability.should be_able_to(:read, Track)
      @ability.should be_able_to(:read, SessionType)
      @ability.should be_able_to(:read, AudienceLevel)
      @ability.should be_able_to(:read, ActsAsTaggableOn::Tag)

      @ability.should be_able_to(:read, 'static_pages')
      @ability.should be_able_to(:manage, 'password_resets')
    end

    it "can login/logout" do
      @ability.should be_able_to(:create, UserSession)
      @ability.should be_able_to(:destroy, UserSession)
    end
    
    it "can create a new account" do
      @ability.should be_able_to(:create, User)
    end
    
    it "can update their own account" do
      @ability.should be_able_to(:update, @user)
      @ability.should_not be_able_to(:update, User.new)
    end

    it "can create comments" do
      @ability.should be_able_to(:create, Comment)
    end
    
    it "can edit their comments" do
      comment = Comment.new
      @ability.should_not be_able_to(:edit, comment)
      comment.user = @user
      @ability.should be_able_to(:edit, comment)
    end
    
    it "can update their comments" do
      comment = Comment.new
      @ability.should_not be_able_to(:update, comment)
      comment.user = @user
      @ability.should be_able_to(:update, comment)
    end

    it "can destroy their comments" do
      comment = Comment.new
      @ability.should_not be_able_to(:destroy, comment)
      comment.user = @user
      @ability.should be_able_to(:destroy, comment)
    end
  end

  context "- all users (guests)" do
    before(:each) do
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "cannot manage reviewer" do
      @ability.should_not be_able_to(:manage, Reviewer)
    end
    
    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end
    
    it "cannot read reviews" do
      @ability.should_not be_able_to(:read, Review)
    end
    
    it "cannot read reviews listing" do
      @ability.should_not be_able_to(:read, 'reviews_listing')
    end
    
    it "cannot read sessions to organize" do
      @ability.should_not be_able_to(:read, 'organizer_sessions')
    end

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end

    describe "can update reviewer if:" do
      before(:each) do
        @reviewer = Factory(:reviewer, :user => @user)
        @reviewer.invite
      end
      
      it "- user is the same" do
        @ability.should be_able_to(:update, @reviewer)
        @reviewer.user = nil
        @ability.should_not be_able_to(:update, @reviewer)
      end
      
      it "- reviewer is in invited state" do
        @ability.should be_able_to(:update, @reviewer)
        @reviewer.preferences.build(:accepted => true, :track_id => 1, :audience_level_id => 1)
        @reviewer.accept
        @ability.should_not be_able_to(:update, @reviewer)
      end
    end
  end
  
  context "- admin" do
    before(:each) do
      @user.add_role "admin"
      @ability = Ability.new(@user, @conference)
    end

    it "can manage all" do
      @ability.should be_able_to(:manage, :all)
    end
  end

  context "- author" do
    before(:each) do
      @user.add_role "author"
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"

    it "cannot manage reviewer" do
      @ability.should_not be_able_to(:manage, Reviewer)
    end
    
    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end
    
    it "cannot read reviews" do
      @ability.should_not be_able_to(:read, Review)
    end
    
    context "index reviews of" do
      before(:each) do
        @decision = Factory(:review_decision, :published => true)
        @session = @decision.session
      end
      
      it "his sessions as first author is allowed" do
        @ability.should_not be_able_to(:index, Review) # no params
        @ability.should_not be_able_to(:index, Review, @session)

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should_not be_able_to(:index, Review) # session id provided
        @ability.should_not be_able_to(:index, Review, @session)
        
        @session.reload.update_attribute(:author_id, @user.id)
        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:index, Review) # session id provided
        @ability.should be_able_to(:index, Review, @session)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:index, Review) # session id nil
        @ability.should be_able_to(:index, Review, @session)
      end

      it "his sessions as second author is allowed" do
        @ability.should_not be_able_to(:index, Review) # no params
        @ability.should_not be_able_to(:index, Review, @session)
        
        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should_not be_able_to(:index, Review) # session id provided
        @ability.should_not be_able_to(:index, Review, @session)

        @session.reload.update_attribute(:second_author_id, @user.id)
        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:index, Review) # session id provided
        @ability.should be_able_to(:index, Review, @session)

        @ability = Ability.new(@user, @conference,  {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:index, Review) # session id nil
        @ability.should be_able_to(:index, Review, @session)
      end
      
      it "his sessions if review has been published" do
        @session.author = @user
        @ability.should be_able_to(:index, Review, @session)
        @session.review_decision.published = false
        @ability.should_not be_able_to(:index, Review, @session)
      end
      
      it "other people's sessions is forbidden" do
        session = Factory(:session)
        @ability.should_not be_able_to(:index, Review) # no params
        @ability.should_not be_able_to(:index, Review, session)
        
        @ability = Ability.new(@user, @conference, :session_id => session.to_param)
        @ability.should_not be_able_to(:index, Review) # session id provided
        @ability.should_not be_able_to(:index, Review, session)  

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:index, Review) # session id nil
        @ability.should_not be_able_to(:index, Review, session)
      end
    end
    
    it "cannot read reviews listing" do
      @ability.should_not be_able_to(:read, 'reviews_listing')
    end
    
    it "cannot read sessions to organize" do
      @ability.should_not be_able_to(:read, 'organizer_sessions')
    end

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end
    
    describe "can create sessions if:" do
      before(:each) do
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
      end
      
      it "- before deadline of 19/3/2011" do
        Time.zone.expects(:now).returns(Time.zone.local(2011, 3, 19, 23, 59, 59))
        @ability.should be_able_to(:create, Session)
      end
      
      it "- after deadline author can't update" do
        Time.zone.expects(:now).returns(Time.zone.local(2011, 3, 20, 0, 0, 0))
        @ability.should_not be_able_to(:create, Session)
      end
    end
    
    describe "can update session if:" do
      before(:each) do
        @session = Factory(:session, :conference => @conference)
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
      end
      
      it "- user is first author" do
        @ability.should_not be_able_to(:update, @session)
        @session.author = @user
        @ability.should be_able_to(:update, @session)
      end
      
      it "- user is second author" do
        @ability.should_not be_able_to(:update, @session)
        @session.second_author = @user
        @ability.should be_able_to(:update, @session)
      end
      
      it "- before deadline of 19/3/2011" do
        @session.author = @user
        Time.zone.expects(:now).returns(Time.zone.local(2011, 3, 19, 23, 59, 59))
        @ability.should be_able_to(:update, @session)
      end
      
      it "- after deadline author can't update" do
        @session.author = @user
        Time.zone.expects(:now).returns(Time.zone.local(2011, 3, 20, 0, 0, 0))
        @ability.should_not be_able_to(:update, @session)
      end

      it "- session on current conference" do
        @session.author = @user
        @ability.should be_able_to(:update, @session)
        @session.conference = Factory(:conference)
        @ability.should_not be_able_to(:update, @session)
      end
    end

    describe "can confirm session if:" do
      before(:each) do
        @another_user = Factory(:user)
        @session = Factory(:session, :author => @user)
        @session.reviewing
        Factory(:review_decision, :session => @session)
        @session.tentatively_accept
        Session.stubs(:find).returns(@session)
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'confirm_sessions') # session id provided

        @session.stubs(:author).returns(@another_user)
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # session id provided

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # session id nil
      end

      it "- session is pending confirmation" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'confirm_sessions') # session id provided

        @session.stubs(:pending_confirmation?).returns(false)
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # session id provided
      end

      it "- session has a review" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'confirm_sessions') # session id provided

        @session.stubs(:review_decision).returns(nil)
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # session id provided
      end

      it "- before deadline of 30/4/2011" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'confirm_sessions') # session id provided

        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2011, 4, 30, 23, 59, 58))
        @ability.should be_able_to(:manage, 'confirm_sessions') # session id provided
      end

      it "- after deadline can't confirm" do
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'confirm_sessions') # session id provided

        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2011, 5, 1, 0, 0, 0))
        @ability.should_not be_able_to(:manage, 'confirm_sessions') # session id provided
      end
    end

    describe "can withdraw session if:" do
      before(:each) do
        @another_user = Factory(:user)
        @session = Factory(:session, :author => @user)
        @session.reviewing
        Factory(:review_decision, :session => @session)
        @session.tentatively_accept
        Session.stubs(:find).returns(@session)
        Time.zone.stubs(:now).returns(Time.zone.local(2010, 1, 1))
      end

      it "- user is first author" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'withdraw_sessions') # session id provided

        @session.stubs(:author).returns(@another_user)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # session id provided

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # session id nil
      end

      it "- session is pending confirmation" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'withdraw_sessions') # session id provided

        @session.stubs(:pending_confirmation?).returns(false)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # session id provided
      end

      it "- session has a review" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'withdraw_sessions') # session id provided

        @session.stubs(:review_decision).returns(nil)
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # session id provided
      end

      it "- before deadline of 30/4/2011" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'withdraw_sessions') # session id provided

        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2011, 4, 30, 23, 59, 58))
        @ability.should be_able_to(:manage, 'withdraw_sessions') # session id provided
      end

      it "- after deadline can't withdraw" do
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # no params

        @ability = Ability.new(@user, @conference, {:session_id => @session.to_param})
        @ability.should be_able_to(:manage, 'withdraw_sessions') # session id provided

        Time.zone.expects(:now).at_least_once.returns(Time.zone.local(2011, 5, 1, 0, 0, 0))
        @ability.should_not be_able_to(:manage, 'withdraw_sessions') # session id provided
      end
    end

  end

  context "- organizer" do
    before(:each) do
      @user.add_role "organizer"
      Factory(:organizer, :user => @user, :conference => @conference)
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"
    
    it "can manage reviewer" do
      @ability.should be_able_to(:manage, Reviewer)
    end
    
    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end

    it "can show reviews" do
      @ability.should be_able_to(:show, Review)
    end
    
    it "can read reviews listing" do
      @ability.should be_able_to(:read, 'reviews_listing')
      @ability.should_not be_able_to(:reviewer, 'reviews_listing')
    end
    
    it "can read sessions to organize" do
      @ability.should be_able_to(:read, 'organizer_sessions')
    end

    it "cannot read sessions to review" do
      @ability.should_not be_able_to(:read, 'reviewer_sessions')
    end
    
    context "organizer index reviews of" do
      before(:each) do
        @session = Factory(:session)
      end
      
      it "session on organizer's track is allowed" do
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should_not be_able_to(:organizer, Review) # no params
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param)
        @ability.should be_able_to(:organizer, Review) # session id provided

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:organizer, Review) # session id nil
      end
      
      it "session outside of organizer's track is forbidden" do
        @ability.should_not be_able_to(:organizer, Review) # no params
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param)
        @ability.should_not be_able_to(:organizer, Review) # session id provided

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:organizer, Review) # session id nil
      end
    end
    
    context "can cancel session if:" do
      before(:each) do
        @session = Factory(:session)
      end
      
      it "- session on organizer's track" do
        @ability.should_not be_able_to(:cancel, @session)

        Factory(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:cancel, @session)

        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:cancel, @session)
      end

      it "- session is not already cancelled" do
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:cancel, @session)
        @session.cancel
        @ability.should_not be_able_to(:cancel, @session)
      end
    end

    context "can create review decision if:" do
      before(:each) do
        @session = Factory(:session)
        @session.reviewing
      end
      
      it "- session on organizer's track" do
        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:create, ReviewDecision)
        
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)

        @ability = Ability.new(@user, @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:create, ReviewDecision)
      end
      
      it "- overrides admin privileges to check if session on organizer's track" do
        @user.add_role('admin')
        
        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:create, ReviewDecision)

        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)

        @ability = Ability.new(@user, @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:create, ReviewDecision)
      end

      it "- session is in review" do
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:create, ReviewDecision)

        @session.reject
        
        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:create, ReviewDecision, @session)
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:create, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:create, ReviewDecision)
      end
    end
    
    context "can edit review decision session" do
      before(:each) do
        @session = Factory(:session)
        @session.reviewing
      end
      
      it " if session on organizer's track" do
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
        
        Factory(:organizer, :track => @session.track, :user => @user)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
      end
      
      it " overrides admin privileges to check if session on organizer's track" do
        @user.add_role('admin')
        
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)

        Factory(:organizer, :track => @session.track, :user => @user)

        @ability = Ability.new(@user, @conference)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "if session was not confirmed by author" do
        @session.tentatively_accept
        @session.accept

        Factory(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
      end

      it "unless session was rejected by author" do
        @session.tentatively_accept
        
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @session.reject
        @session.author_agreement = true;
        @session.save
        
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
      end
      
      it "unless session was accepted by author" do
        @session.tentatively_accept
        
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)

        @session.accept
        @session.author_agreement = true;
        @session.save
        
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
      end
      
      it "if session has a review decision" do
        Factory(:organizer, :track => @session.track, :user => @user)
        @ability.should_not be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should_not be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
      end
      
      it "if session is rejected" do
        @session.reject
        
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
      end
      
      it "if session is tentatively accepted" do
        @session.tentatively_accept
        
        Factory(:organizer, :track => @session.track, :user => @user, :conference => @conference)
        @ability.should be_able_to(:update, ReviewDecision, @session)
        @ability.should_not be_able_to(:update, ReviewDecision)
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param) # session id provided
        @ability.should be_able_to(:update, ReviewDecision)

        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil}) # session id nil
        @ability.should_not be_able_to(:update, ReviewDecision)
      end
    end
  end

  context "- reviewer" do
    before(:each) do
      @user.add_role "reviewer"
      Factory(:reviewer, :user => @user, :conference => @conference)
      @ability = Ability.new(@user, @conference)
    end

    it_should_behave_like "all users"
    
    it "cannot read organizers" do
      @ability.should_not be_able_to(:read, Organizer)
    end

    it "cannot read other reviewers" do
      @ability.should_not be_able_to(:read, Reviewer)
    end
    
    it "cannot read organizer's sessions" do
      @ability.should_not be_able_to(:read, 'organizer_sessions')
    end

    it "can read sessions to review" do
      @ability.should be_able_to(:read, 'reviewer_sessions')
    end
    
    it "can read reviews listing" do
      @ability.should be_able_to(:read, 'reviews_listing')
      @ability.should be_able_to(:reviewer, 'reviews_listing')
    end
    
    it "cannot index all reviews of any session" do
      @ability.should_not be_able_to(:index, Review)
    end

    it "cannot index all organizer reviews of any session" do
      @ability.should_not be_able_to(:organizer, Review)
    end

    it "can show own reviews" do
      review = Factory(:review)
      @ability.should_not be_able_to(:show, review)
      review.reviewer = @user
      @ability.should be_able_to(:show, review)
    end

    context "can create a new review if:" do
      before(:each) do
        @session = Factory(:session)
        Session.stubs(:for_reviewer).with(@user, @conference).returns([@session])
      end
      
      it "has not created a review for this session" do
        @ability.should be_able_to(:create, Review, @session)
      
        Session.expects(:for_reviewer).with(@user, @conference).returns([])
        @ability.should_not be_able_to(:create, Review, @session)
      end
      
      it "has a session available to add the review to" do
        @ability.should_not be_able_to(:create, Review)
        @ability.should_not be_able_to(:create, Review, nil)
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param)
        @ability.should be_able_to(:create, Review)
        @ability.should be_able_to(:create, Review, nil)
        @ability.should be_able_to(:create, Review, @session)
        
        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:create, Review)
        @ability.should_not be_able_to(:create, Review, nil)
      end
      
      it "overrides admin privileges to check if session available" do
        @user.add_role('admin')
        
        @ability.should_not be_able_to(:create, Review)
        @ability.should_not be_able_to(:create, Review, nil)
        
        @ability = Ability.new(@user, @conference, :session_id => @session.to_param)
        @ability.should be_able_to(:create, Review)
        @ability.should be_able_to(:create, Review, nil)
        @ability.should be_able_to(:create, Review, @session)
        
        @ability = Ability.new(@user, @conference, {:locale => 'pt', :session_id => nil})
        @ability.should_not be_able_to(:create, Review)
        @ability.should_not be_able_to(:create, Review, nil)
      end
    end
  end
end

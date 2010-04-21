require 'spec/spec_helper'

describe Session do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :title
    should_allow_mass_assignment_of :summary
    should_allow_mass_assignment_of :description
    should_allow_mass_assignment_of :mechanics
    should_allow_mass_assignment_of :benefits
    should_allow_mass_assignment_of :target_audience
    should_allow_mass_assignment_of :audience_limit
    should_allow_mass_assignment_of :author_id
    should_allow_mass_assignment_of :second_author_username
    should_allow_mass_assignment_of :track_id
    should_allow_mass_assignment_of :session_type_id
    should_allow_mass_assignment_of :audience_level_id
    should_allow_mass_assignment_of :duration_mins
    should_allow_mass_assignment_of :experience
    should_allow_mass_assignment_of :keyword_list
  
    should_not_allow_mass_assignment_of :evil_attr
  end
  
  it_should_trim_attributes Session, :title, :summary, :description, :mechanics, :benefits,
                                     :target_audience, :second_author_username, :experience
  
  context "associations" do
    should_belong_to :author, :class_name => 'User'
    should_belong_to :second_author, :class_name => 'User'
    should_belong_to :track
    should_belong_to :session_type
    should_belong_to :audience_level
    
    should_have_many :comments, :as => :commentable, :dependent => :destroy
    
    should_have_many :reviews
    
    context "second author association by username" do
      before(:each) do
        @session = Factory(:session)
        @user = Factory(:user)
      end
      
      it "should set by username" do
        @session.second_author_username = @user.username
        @session.second_author.should == @user
      end
    
      it "should not set if username is nil" do
        @session.second_author_username = nil
        @session.second_author.should be_nil
      end

      it "should not set if username is empty" do
        @session.second_author_username = ""
        @session.second_author.should be_nil
      end

      it "should not set if username is only spaces" do
        @session.second_author_username = "  "
        @session.second_author.should be_nil
      end
      
      it "should provide username from association" do
        @session.second_author_username.should be_nil
        @session.second_author_username = @user.username
        @session.second_author_username.should == @user.username
      end
    end
  end
  
  context "validations" do
    should_validate_presence_of :title
    should_validate_presence_of :summary
    should_validate_presence_of :description
    should_validate_presence_of :benefits
    should_validate_presence_of :target_audience
    should_validate_presence_of :author_id
    should_validate_presence_of :track_id
    should_validate_presence_of :session_type_id
    should_validate_presence_of :audience_level_id
    should_validate_presence_of :experience
    should_validate_presence_of :duration_mins
    should_validate_presence_of :keyword_list
    should_validate_inclusion_of :duration_mins, :in => [45, 90], :allow_blank => true
    
    should_validate_numericality_of :audience_limit, :only_integer => true, :greater_than => 0, :allow_nil => true
    
    should_validate_length_of :title, :maximum => 100
    should_validate_length_of :target_audience, :maximum => 200
    should_validate_length_of :summary, :maximum => 800
    should_validate_length_of :description, :maximum => 2400
    should_validate_length_of :mechanics, :maximum => 2400, :allow_blank => true
    should_validate_length_of :benefits, :maximum => 400
    should_validate_length_of :experience, :maximum => 400
    
    context "workshop" do
      it "should validate presence of mechanics" do
        session = Factory(:session)
        session.mechanics = nil
        session.should be_valid
        session.session_type = SessionType.new(:title => 'session_types.workshop.title')
        session.should_not be_valid
      end
    end
    
    context "second author" do
      before(:each) do
        @session = Factory(:session)
      end
      
      it "should be a valid user" do
        @session.second_author_username = 'invalid_username'
        @session.should_not be_valid
        @session.errors.on(:second_author_username).should include("não existe")
      end
      
      it "should not be the same as first author" do
        @session.second_author_username = @session.author.username
        @session.should_not be_valid
        @session.errors.on(:second_author_username).should include("não pode ser o mesmo autor")
      end
      
      it "should be author" do
        guest = Factory(:user)
        @session.second_author_username = guest.username
        @session.should_not be_valid
        @session.errors.on(:second_author_username).should include("perfil de autor incompleto")
      end
    end
    
    context "experience report" do
      before(:each) do
        @talk = SessionType.new(:title => 'session_types.talk.title')
        @session = Factory(:session)
        @session.track = Track.new(:title => 'tracks.experience_reports.title')
        @session.session_type = @talk
      end
      
      it "should only have duration of 45 minutes" do
        @session.duration_mins = 45
        @session.should be_valid
        @session.duration_mins = 90
        @session.should_not be_valid
      end

      it "should only be talk" do
        @session.session_type = @talk
        @session.should be_valid
        @session.session_type = SessionType.new(:title => 'session_types.workshop.title')
        @session.should_not be_valid
      end
    end
    
    it "should validate that author doesn't change" do
      session = Factory(:session)
      session.author_id = 99
      session.should_not be_valid
      session.errors.on(:author_id).should == "não pode mudar"
    end
  end
  
  context "named scopes" do
    it {should have_scope(:for_user).conditions(['author_id = ? OR second_author_id = ?', 3, 3]).with('3') }

    it {should have_scope(:for_tracks).conditions(['track_id IN (?)', [1, 2]]).with([1, 2]) }
 
    context "for reviewer" do
      context "on accepted preferences" do
        it "no preferences" do
          # If user has no preference, no sessions to review
          should have_scope(:for_preferences).conditions('1 = 2').with()
        end
        
        it "one preference" do
          should have_scope(:for_preferences).conditions([
            '(track_id = ? AND audience_level_id <= ?)',
            1, 2
          ]).with(Preference.new(:track_id => 1, :audience_level_id => 2))
        end
        
        it "multiple preferences" do
          should have_scope(:for_preferences).conditions([
            '(track_id = ? AND audience_level_id <= ?) OR (track_id = ? AND audience_level_id <= ?)',
            1, 2, 3, 4
          ]).with(
            Preference.new(:track_id => 1, :audience_level_id => 2),
            Preference.new(:track_id => 3, :audience_level_id => 4)
          )
        end
      end
      
      it "non cancelled" do
        should have_scope(:without_states).conditions(['state NOT IN (?)', ["cancelled"]]).with(:cancelled)
      end
      
      it "if not author" do
        should have_scope(:not_author).conditions(['author_id <> ? AND (second_author_id IS NULL OR second_author_id <> ?)', 3, 3]).with('3')
      end
      
      it "with less than 3 reviews" do
        should have_scope(:incomplete_reviews).conditions(['reviews_count < ?', 3]).with(3)
      end
      
      it "if not already reviewed by user" do
        should have_scope(:reviewed_by).joins(:reviews).conditions(['reviewer_id = ?', 3]).with('3')
      end
      
      it "should combine criteria" do
        reviewer = Factory(:reviewer)
        Session.expects(:incomplete_reviews).with(3).returns(Session)
        Session.expects(:not_author).with(reviewer.user.id).returns(Session)
        Session.expects(:without_state).with(:cancelled).returns(Session)
        Session.expects(:for_preferences).with(*reviewer.preferences).returns(Session)
        
        Session.expects(:reviewed_by).with(reviewer.user.id).returns(Session)
        
        Session.expects(:all).times(2).then.returns([1, 2, 3, 4]).then.returns([2, 3, 6])
        
        Session.for_reviewer(reviewer.user).should == [1, 4]
      end
    end
  end
  
  it "should determine if it's workshop" do
    workshop = SessionType.new(:title => 'session_types.workshop.title')
    session = Factory(:session)
    session.should_not be_workshop
    session.session_type = workshop
    session.should be_workshop
  end

  it "should determine if it's experience_report" do
    experience_report = Track.new(:title => 'tracks.experience_reports.title')
    session = Factory(:session)
    session.should_not be_experience_report
    session.track = experience_report
    session.should be_experience_report
  end
  
  it "should overide to_param with session title" do
    session = Factory(:session, :title => "refatoração e código limpo: na prática.")
    session.to_param.ends_with?("-refatoracao-e-codigo-limpo-na-pratica").should be_true
    
    session.title = nil
    session.to_param.ends_with?("-refatoracao-e-codigo-limpo-na-pratica").should be_false
  end
  
  context "authors" do
    it "should provide main author" do
      session = Factory(:session)
      session.authors.should == [session.author]
    end
    
    it "should provide second author if available" do
      user = Factory(:user)
      user.add_role(:author)
      session = Factory(:session, :second_author => user)
      session.authors.should == [session.author, user]      
    end
    
    it "should be empty if no authors" do
      session = Factory(:session)
      session.author = nil
      session.authors.should be_empty
    end
    
    it "should state that first author is author" do
      user = Factory(:user)
      user.add_role(:author)
      
      session = Factory(:session, :author => user)
      session.is_author?(user).should be_true
      session.author = nil
      session.is_author?(user).should be_false
    end

    it "should state that second author is author" do
      user = Factory(:user)
      user.add_role(:author)
      
      session = Factory(:session, :second_author => user)
      session.is_author?(user).should be_true
      session.second_author = nil
      session.is_author?(user).should be_false
    end
  end
  
  context "state machine" do
    before(:each) do
      @session = Factory.build(:session)
    end
    
    context "State: created" do
      it "should be the initial state" do
        @session.should be_created
      end
      
      it "should allow reviewing" do
        @session.reviewing.should be_true
        @session.should_not be_created
        @session.should be_in_review
      end

      it "should allow cancel" do
        @session.cancel.should be_true
        @session.should_not be_created
        @session.should be_cancelled
      end

      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be_false
      end

      it "should not allow accepting" do
        @session.accept.should be_false
      end

      it "should not allow rejecting" do
        @session.reject.should be_false
      end
    end
    
    context "State: in review" do
      before(:each) do
        @session.reviewing
        @session.should be_in_review
      end
      
      it "should allow reviewing again" do
        @session.reviewing.should be_true
        @session.should be_in_review
      end
      
      it "should allow cancel" do
        @session.cancel.should be_true
        @session.should_not be_in_review
        @session.should be_cancelled
      end

      it "should allow tentatively accept" do
        @session.tentatively_accept.should be_true
        @session.should_not be_in_review
        @session.should be_pending_confirmation
      end

      it "should not allow accepting" do
        @session.accept.should be_false
      end

      it "should not allow rejecting" do
        @session.reject.should be_false
      end
    end

    context "State: cancelled" do
      before(:each) do
        @session.cancel
        @session.should be_cancelled
      end
      
      it "should not allow reviewing" do
        @session.reviewing.should be_false
      end
      
      it "should not allow cancelling" do
        @session.cancel.should be_false
      end

      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be_false
      end
      
      it "should not allow accepting" do
        @session.accept.should be_false
      end

      it "should not allow rejecting" do
        @session.reject.should be_false
      end
    end
    
    context "State: pending confirmation" do
      before(:each) do
        @session.reviewing
        @session.tentatively_accept
        @session.should be_pending_confirmation
      end
      
      it "should not allow reviewing" do
        @session.reviewing.should be_false
      end
      
      it "should not allow cancelling" do
        @session.cancel.should be_false
      end
      
      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be_false
      end

      it "should allow accepting" do
        @session.accept.should be_true
        @session.should_not be_pending_confirmation
        @session.should be_accepted
      end

      it "should allow rejecting" do
        @session.reject.should be_true
        @session.should_not be_pending_confirmation
        @session.should be_rejected
      end
    end

    context "State: accepted" do
      before(:each) do
        @session.reviewing
        @session.tentatively_accept
        @session.accept
        @session.should be_accepted
      end
      
      it "should not allow reviewing" do
        @session.reviewing.should be_false
      end
      
      it "should not allow cancelling" do
        @session.cancel.should be_false
      end
      
      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be_false
      end

      it "should not allow accepting" do
        @session.accept.should be_false
      end
      
      it "should not allow rejecting" do
        @session.reject.should be_false
      end
    end

    context "State: rejected" do
      before(:each) do
        @session.reviewing
        @session.tentatively_accept
        @session.reject
        @session.should be_rejected
      end
      
      it "should not allow reviewing" do
        @session.reviewing.should be_false
      end
      
      it "should not allow cancelling" do
        @session.cancel.should be_false
      end
      
      it "should allow tentatively accept" do
        @session.tentatively_accept.should be_true
        @session.should_not be_rejected
        @session.should be_pending_confirmation
      end

      it "should not allow accepting" do
        @session.accept.should be_false
      end
      
      it "should not allow rejecting" do
        @session.reject.should be_false
      end
    end
  end
  
end
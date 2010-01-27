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
  
  context "associations" do
    should_belong_to :author, :class_name => 'User'
    should_belong_to :second_author, :class_name => 'User'
    should_belong_to :track
    should_belong_to :session_type
    should_belong_to :audience_level
    
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
    
    context "workshop" do
      it "should validate presence of mechanics" do
        session = Factory(:session)
        session.mechanics = nil
        session.should be_valid
        session.session_type = SessionType.find_by_title('session_types.workshop.title')
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
        @session.errors.on(:second_author_username).should == "não existe"
      end
      
      it "should not be the same as first author" do
        @session.second_author_username = @session.author.username
        @session.should_not be_valid
        @session.errors.on(:second_author_username).should == "não pode ser o mesmo autor"
      end
    end
    
    context "experience report" do
      before(:each) do
        experience_report = Track.find_by_title('tracks.experience_reports.title')
        @talk = SessionType.find_by_title('session_types.talk.title')
        @session = Factory(:session, :track => experience_report, :session_type => @talk)
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
        @session.session_type = SessionType.find_by_title('session_types.workshop.title')
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
    should_have_scope :for_user, :conditions => ['author_id = ? OR second_author_id = ?', 3, 3], :with => '3'
  end
  
  it "should determine if it's workshop" do
    workshop = SessionType.find_by_title('session_types.workshop.title')
    session = Factory(:session)
    session.should_not be_workshop
    session.session_type = workshop
    session.should be_workshop
  end

  it "should determine if it's experience_report" do
    experience_report = Track.find_by_title('tracks.experience_reports.title')
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
  
end
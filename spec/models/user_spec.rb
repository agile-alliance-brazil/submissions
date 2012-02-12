# encoding: UTF-8
# encoding: utf-8
require 'spec_helper'

describe User do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :first_name
    should_allow_mass_assignment_of :last_name
    should_allow_mass_assignment_of :username
    should_allow_mass_assignment_of :email
    should_allow_mass_assignment_of :password
    should_allow_mass_assignment_of :password_confirmation
    should_allow_mass_assignment_of :phone
    should_allow_mass_assignment_of :country
    should_allow_mass_assignment_of :state
    should_allow_mass_assignment_of :city
    should_allow_mass_assignment_of :organization
    should_allow_mass_assignment_of :website_url
    should_allow_mass_assignment_of :bio
    should_allow_mass_assignment_of :wants_to_submit
    should_allow_mass_assignment_of :default_locale
  
    should_not_allow_mass_assignment_of :id
  end
  
  it_should_trim_attributes User, :first_name, :last_name, :username,
                                  :email, :phone, :state, :city, :organization,
                                  :website_url, :bio

  context "validations" do
    should_validate_presence_of :first_name
    should_validate_presence_of :last_name
    
    context "brazilians" do
      subject { Factory.build(:user, :country => "BR") }
      should_not_validate_presence_of :state
    end
    
    context "author" do
      subject { u = Factory.build(:user); u.add_role("author"); u }
      should_validate_presence_of :phone
      should_validate_presence_of :country
      should_validate_presence_of :city
      should_validate_presence_of :bio
      
      should_allow_values_for :phone, "1234-2345", "+55 11 5555 2234", "+1 (304) 543.3333", "07753423456"
      should_not_allow_values_for :phone, "a", "1234-bfd", ")(*&^%$@!", "[=+]"

      context "brazilians" do
        subject { u = Factory.build(:user, :country => "BR"); u.add_role("author"); u }
        should_validate_presence_of :state
      end
    end
    
    should_validate_length_of :username, :minimum => 3, :maximum => 30
    should_validate_length_of :password, :within => 3..30
    should_validate_length_of :email, :minimum => 6, :maximum => 100
    should_validate_length_of :first_name, :maximum => 100, :allow_blank => true
    should_validate_length_of :last_name, :maximum => 100, :allow_blank => true
    should_validate_length_of :city, :maximum => 100, :allow_blank => true
    should_validate_length_of :organization, :maximum => 100, :allow_blank => true
    should_validate_length_of :website_url, :maximum => 100, :allow_blank => true
    should_validate_length_of :phone, :maximum => 100, :allow_blank => true
    should_validate_length_of :bio, :maximum => 1600, :allow_blank => true
    
    should_allow_values_for :username, "dtsato", "123", "a b c", "danilo.sato", "dt-sato@dt_sato.com"
    should_not_allow_values_for :username, "dt$at0", "<>/?", ")(*&^%$@!", "[=+]"
    
    should_allow_values_for :email, "user@domain.com.br", "test_user.name@a.co.uk"
    should_not_allow_values_for :email, "a", "a@", "a@a", "@12.com"

    should_validate_uniqueness_of :email
    should_validate_uniqueness_of :username, :case_sensitive => false
        
    should_validate_confirmation_of :password
    
    it "should validate that username doesn't change" do
      user = Factory(:user)
      user.username = 'new_username'
      user.should_not be_valid
      user.errors[:username].should == ["não pode mudar"]
    end
  end
  
  context "associations" do
    should_have_many :sessions, :foreign_key => 'author_id'
    should_have_many :organizers
    should_have_many :all_organized_tracks, :through => :organizers, :source => :track
    should_have_many :reviewers
    should_have_many :reviews, :foreign_key => 'reviewer_id'

    describe "organized tracks for conference" do
      it "should narrow tracks based on conference" do
        organizer = Factory(:organizer)
        user = organizer.user
        Factory(:organizer, :user => user)

        user.organized_tracks(organizer.conference).should == [organizer.track]
      end
    end
    
    describe "#has_approved_session?" do
      it "should not have approved long sessions if never submited" do
         user = Factory(:user)
         user.should_not have_approved_session(Factory(:conference))
      end
      
      it "should not have approved long sessions if accepted was on another conference" do
         user = Factory(:user)
         old_conference = Factory(:conference)
         current = Factory(:conference)
         session = Factory(:session, :author => user, :conference => old_conference)

         user.should_not have_approved_session(current)
      end
      
      it "should have approved long sessions if accepted was lightning talk" do
         user = Factory(:user)
         session = Factory(:session, :author => user, :session_type_id => 4, :duration_mins => 10, :state => 'accepted')

         user.should have_approved_session(session.conference)
      end
      
      it "should have approved long sessions if accepted was not lightning talk" do
         user = Factory(:user)
         session = Factory(:session, :author => user, :session_type_id => 1, :state => 'accepted')

         user.should have_approved_session(session.conference)
      end

      it "should have approved long sessions if accepted contains at least one non lightning talk" do
        user = Factory(:user)
        session = Factory(:session, :author => user, :session_type_id => 1, :state => 'accepted')
        lightning_talk = Factory(:session, :author => user, :session_type_id => 4, :duration_mins => 10,  :state => 'accepted')

        user.should have_approved_session(session.conference)
      end

      it "should not have approved long sessions if no sessions was not accepted" do
        user = Factory(:user)
        session = Factory(:session, :author => user, :session_type_id => 1, :state => 'cancelled')
        lightning_talk = Factory(:session, :author => user, :session_type_id => 4, :duration_mins => 10,  :state => 'rejected')

        user.should_not have_approved_session(session.conference)
      end

      it "should have approved sessions as second author" do
         user = Factory(:user)
         user.add_role :author
         session = Factory(:session, :second_author => user, :session_type_id => 1, :state => 'accepted')

         user.should have_approved_session(session.conference)
      end
    end

    describe "user preferences" do
      it "should return reviewer preferences based on conference" do
        preference = Factory(:preference)
        reviewer = preference.reviewer
        user = reviewer.user
        Factory(:preference, :reviewer => Factory(:reviewer, :user => user))

        user.preferences(reviewer.conference).should == [preference] 
      end
    end
  end
  
  context "named scopes" do
    xit { should have_scope(:search, :with =>'danilo', :where => "username LIKE '%danilo%'") }
  end
  
  context "authorization" do
    it "should have role of author when wants to submit" do
      User.new(:wants_to_submit => '0').should_not be_author
      User.new(:wants_to_submit => '1').should be_author
    end
  end
  
  it "should provide full name" do
    user = User.new(:first_name => "Danilo", :last_name => "Sato")
    user.full_name.should == "Danilo Sato"
  end
  
  it "should provide in_brazil?" do
    user = User.new
    user.should_not be_in_brazil
    user.country = "BR"
    user.should be_in_brazil
  end
  
  it "should overide to_param with username" do
    user = Factory(:user, :username => 'danilo.sato 1990@2')
    user.to_param.ends_with?("-danilo-sato-1990-2").should be_true
    
    user.username = nil
    user.to_param.ends_with?("-danilo-sato-1990-2").should be_false
  end
  
  it "should have 'pt' as default locale" do
    user = Factory(:user)
    user.default_locale.should == 'pt'
  end
end

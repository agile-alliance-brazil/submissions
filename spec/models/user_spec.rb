# encoding: UTF-8
require 'spec_helper'

describe User do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :first_name }
    it { should allow_mass_assignment_of :last_name }
    it { should allow_mass_assignment_of :username }
    it { should allow_mass_assignment_of :email }
    it { should allow_mass_assignment_of :password }
    it { should allow_mass_assignment_of :password_confirmation }
    it { should allow_mass_assignment_of :phone }
    it { should allow_mass_assignment_of :country }
    it { should allow_mass_assignment_of :state }
    it { should allow_mass_assignment_of :city }
    it { should allow_mass_assignment_of :organization }
    it { should allow_mass_assignment_of :website_url }
    it { should allow_mass_assignment_of :bio }
    it { should allow_mass_assignment_of :wants_to_submit }
    it { should allow_mass_assignment_of :default_locale }
    it { should allow_mass_assignment_of :twitter_username }

    it { should_not allow_mass_assignment_of :id }
  end

  context "trimming" do
    it_should_trim_attributes User, :first_name, :last_name, :username,
                                    :email, :phone, :city, :organization,
                                    :website_url, :bio, :twitter_username
    it "should trim state if country is Brazil" do
      user = FactoryGirl.build(:user, :state => '  Rio de Janeiro  ', :country => 'BR')
      user.should be_valid
      user.state.should == 'Rio de Janeiro'
    end
  end

  context "before validations" do
    it "should trim @ from twitter username if present" do
      user = FactoryGirl.build(:user, :twitter_username => '@dtsato')
      user.should be_valid
      user.twitter_username.should == 'dtsato'

      user = FactoryGirl.build(:user, :twitter_username => '  @dtsato  ')
      user.should be_valid
      user.twitter_username.should == 'dtsato'
    end

    it "should not change twitter username if @ is not present" do
      user = FactoryGirl.build(:user, :twitter_username => 'dtsato')
      user.should be_valid
      user.twitter_username.should == 'dtsato'

      user = FactoryGirl.build(:user, :twitter_username => '  dtsato  ')
      user.should be_valid
      user.twitter_username.should == 'dtsato'
    end

    it "should remove state for non brazilians" do
      user = FactoryGirl.build(:user, :country => "US", :state => "Illinois").tap {|u| u.add_role("author") }
      user.should be_valid
      user.state.should be_empty
    end
  end

  context "validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }

    context "brazilians" do
      subject { FactoryGirl.build(:user, :country => "BR") }
      it { should_not validate_presence_of :state }
    end

    context "author" do
      subject { FactoryGirl.build(:user).tap {|u| u.add_role("author") } }
      it { should validate_presence_of :phone }
      it { should validate_presence_of :country }
      it { should validate_presence_of :city }
      it { should validate_presence_of :bio }

      it { should allow_value("1234-2345").for(:phone) }
      it { should allow_value("+55 11 5555 2234").for(:phone) }
      it { should allow_value("+1 (304) 543.3333").for(:phone) }
      it { should allow_value("07753423456").for(:phone) }
      it { should_not allow_value("a").for(:phone) }
      it { should_not allow_value("1234-bfd").for(:phone) }
      it { should_not allow_value(")(*&^%$@!").for(:phone) }
      it { should_not allow_value("[=+]").for(:phone) }

      context "brazilians" do
        subject { FactoryGirl.build(:user, :country => "BR").tap {|u| u.add_role("author") } }
        it { should validate_presence_of :state }
      end
    end

    it { should ensure_length_of(:username).is_at_least(3).is_at_most(30) }
    it { should ensure_length_of(:password).is_at_least(3).is_at_most(30) }
    it { should ensure_length_of(:email).is_at_least(6).is_at_most(100) }
    it { should ensure_length_of(:first_name).is_at_most(100) }
    it { should ensure_length_of(:last_name).is_at_most(100) }
    it { should ensure_length_of(:city).is_at_most(100) }
    it { should ensure_length_of(:organization).is_at_most(100) }
    it { should ensure_length_of(:website_url).is_at_most(100) }
    it { should ensure_length_of(:phone).is_at_most(100) }
    it { should ensure_length_of(:bio).is_at_most(1600) }

    it { should allow_value("dtsato").for(:username) }
    it { should allow_value("123").for(:username) }
    it { should allow_value("a b c").for(:username) }
    it { should allow_value("danilo.sato").for(:username) }
    it { should allow_value("dt-sato@dt_sato.com").for(:username) }
    it { should_not allow_value("dt$at0").for(:username) }
    it { should_not allow_value("<>/?").for(:username) }
    it { should_not allow_value(")(*&^%$@!").for(:username) }
    it { should_not allow_value("[=+]").for(:username) }

    it { should allow_value("user@domain.com.br").for(:email) }
    it { should allow_value("test_user.name@a.co.uk").for(:email) }
    it { should_not allow_value("a").for(:email) }
    it { should_not allow_value("a@").for(:email) }
    it { should_not allow_value("a@a").for(:email) }
    it { should_not allow_value("@12.com").for(:email) }

    context "uniqueness" do
      subject { FactoryGirl.create(:user, :country => "BR") }

      it { should validate_uniqueness_of(:email).with_message(I18n.t("activerecord.errors.models.user.attributes.email.taken")) }
      it { should validate_uniqueness_of(:username).case_insensitive }
    end

    xit { should validate_confirmation_of :password }

    it "should validate that username doesn't change" do
      user = FactoryGirl.create(:user)
      user.username = 'new_username'
      user.should_not be_valid
      user.errors[:username].should include(I18n.t("errors.messages.constant"))
    end
  end

  context "associations" do
    it { should have_many :sessions }
    it { should have_many :organizers }
    it { should have_many(:all_organized_tracks).through(:organizers) }
    it { should have_many :reviewers }
    it { should have_many :reviews }
    it { should have_many :early_reviews }
    it { should have_many :final_reviews }

    describe "organized tracks for conference" do
      it "should narrow tracks based on conference" do
        organizer = FactoryGirl.create(:organizer)
        user = organizer.user
        old_track = FactoryGirl.create(:track, :conference => Conference.first)
        FactoryGirl.create(:organizer, :user => user, :track => old_track, :conference => Conference.first)

        user.organized_tracks(organizer.conference).should == [organizer.track]
      end
    end

    describe "sessions for conference" do
      it "should narrow sessions based on conference for user" do
        session = FactoryGirl.create(:session)
        FactoryGirl.create(:session)
        FactoryGirl.create(:session, :conference => Conference.first, :track => Track.first, :audience_level => AudienceLevel.first, :session_type => SessionType.first, :author => session.author)
        user = session.author

        user.sessions_for_conference(Conference.current).should == [session]
      end

      it "should return session where user is second author" do
        session = FactoryGirl.create(:session)
        user = session.author
        user.add_role :author

        another_session = FactoryGirl.create(:session, :second_author => user)

        user.sessions_for_conference(Conference.current).should == [session, another_session]
      end
    end

    describe "#has_approved_session?" do
      before(:each) do
        conference_with_lightning_talks = Conference.find(3)
        @lightning_talk = conference_with_lightning_talks.session_types.find {|st| st.lightning_talk? }
        @non_lightning_talk = conference_with_lightning_talks.session_types.find {|st| !st.lightning_talk? }
      end

      it "should not have approved long sessions if never submited" do
         user = FactoryGirl.build(:user)
         user.should_not have_approved_session(Conference.current)
      end

      it "should not have approved long sessions if accepted was on another conference" do
         user = FactoryGirl.build(:user)
         session = FactoryGirl.build(:session, :author => user, :conference => Conference.first)

         user.should_not have_approved_session(Conference.current)
      end

      it "should have approved long sessions if accepted was lightning talk" do
         user = FactoryGirl.create(:user)
         session = FactoryGirl.create(:session, :author => user, :session_type => @lightning_talk, :duration_mins => 10, :state => 'accepted', :conference => @lightning_talk.conference)

         user.should have_approved_session(session.conference)
      end

      it "should have approved long sessions if accepted was not lightning talk" do
         user = FactoryGirl.create(:user)
         session = FactoryGirl.create(:session, :author => user, :session_type => @non_lightning_talk, :state => 'accepted', :conference => @non_lightning_talk.conference)

         user.should have_approved_session(session.conference)
      end

      it "should have approved long sessions if accepted contains at least one non lightning talk" do
        user = FactoryGirl.create(:user)
        session = FactoryGirl.create(:session, :author => user, :session_type => @non_lightning_talk, :state => 'accepted', :conference => @non_lightning_talk.conference)
        lightning_talk = FactoryGirl.create(:session, :author => user, :session_type => @lightning_talk, :duration_mins => 10,  :state => 'accepted', :conference => @lightning_talk.conference)

        user.should have_approved_session(session.conference)
      end

      it "should not have approved long sessions if no sessions was not accepted" do
        user = FactoryGirl.build(:user)
        session = FactoryGirl.build(:session, :author => user, :session_type => @non_lightning_talk, :state => 'cancelled', , :conference => @non_lightning_talk.conference)
        lightning_talk = FactoryGirl.build(:session, :author => user, :session_type => @lightning_talk, :duration_mins => 10,  :state => 'rejected', :conference => @lightning_talk.conference)

        user.should_not have_approved_session(session.conference)
      end

      it "should have approved sessions as second author" do
         user = FactoryGirl.create(:user)
         user.add_role :author
         session = FactoryGirl.create(:session, :second_author => user, :state => 'accepted')

         user.should have_approved_session(session.conference)
      end
    end

    describe "user preferences" do
      it "should return reviewer preferences based on conference" do
        preference = FactoryGirl.create(:preference)
        reviewer = preference.reviewer
        user = reviewer.user
        FactoryGirl.create(:preference,
          :reviewer => FactoryGirl.create(:reviewer, :user => user, :conference => Conference.first))

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
    user = FactoryGirl.create(:user, :username => 'danilo.sato 1990@2')
    user.to_param.ends_with?("-danilo-sato-1990-2").should be_true

    user.username = nil
    user.to_param.ends_with?("-danilo-sato-1990-2").should be_false
  end

  it "should have 'pt' as default locale" do
    user = FactoryGirl.build(:user)
    user.default_locale.should == 'pt'
  end
end

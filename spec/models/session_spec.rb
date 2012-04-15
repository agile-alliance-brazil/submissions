# encoding: UTF-8
require 'spec_helper'

describe Session do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :title }
    it { should allow_mass_assignment_of :summary }
    it { should allow_mass_assignment_of :description }
    it { should allow_mass_assignment_of :mechanics }
    it { should allow_mass_assignment_of :benefits }
    it { should allow_mass_assignment_of :target_audience }
    it { should allow_mass_assignment_of :audience_limit }
    it { should allow_mass_assignment_of :author_id }
    it { should allow_mass_assignment_of :second_author_username }
    it { should allow_mass_assignment_of :track_id }
    it { should allow_mass_assignment_of :session_type_id }
    it { should allow_mass_assignment_of :audience_level_id }
    it { should allow_mass_assignment_of :duration_mins }
    it { should allow_mass_assignment_of :experience }
    it { should allow_mass_assignment_of :keyword_list }
    it { should allow_mass_assignment_of :author_agreement }
    it { should allow_mass_assignment_of :image_agreement }
    it { should allow_mass_assignment_of :state_event }
    it { should allow_mass_assignment_of :conference_id }

    it { should_not allow_mass_assignment_of :id }
  end

  it_should_trim_attributes Session, :title, :summary, :description, :mechanics, :benefits,
                                     :target_audience, :second_author_username, :experience

  context "associations" do
    it { should belong_to(:author).class_name('User') }
    it { should belong_to(:second_author).class_name('User') }
    it { should belong_to :track }
    it { should belong_to :session_type }
    it { should belong_to :audience_level }
    it { should belong_to :conference }

    it { should have_many(:comments).dependent(:destroy) }

    it { should have_many :early_reviews }
    it { should have_many :final_reviews }
    it { should have_one  :review_decision }

    context "second author association by username" do
      before(:each) do
        @session = FactoryGirl.create(:session)
        @user = FactoryGirl.create(:user)
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
    it { should validate_presence_of :title }
    it { should validate_presence_of :summary }
    it { should validate_presence_of :description }
    it { should validate_presence_of :benefits }
    it { should validate_presence_of :target_audience }
    it { should validate_presence_of :author_id }
    it { should validate_presence_of :track_id }
    it { should validate_presence_of :conference_id }
    it { should validate_presence_of :session_type_id }
    it { should validate_presence_of :audience_level_id }
    it { should validate_presence_of :experience }
    it { should validate_presence_of :duration_mins }
    it { should validate_presence_of :keyword_list }
    xit { should validate_inclusion_of(:duration_mins).in_range([10, 50, 110]) }

    should_validate_existence_of :conference, :author
    should_validate_existence_of :track, :session_type, :audience_level, :allow_blank => true

    it { should validate_numericality_of :audience_limit }

    it { should ensure_length_of(:title).is_at_most(100) }
    it { should ensure_length_of(:target_audience).is_at_most(200) }
    it { should ensure_length_of(:summary).is_at_most(800) }
    it { should ensure_length_of(:description).is_at_most(2400) }
    it { should ensure_length_of(:mechanics).is_at_most(2400) }
    it { should ensure_length_of(:benefits).is_at_most(400) }
    it { should ensure_length_of(:experience).is_at_most(400) }

    context "track" do
      it "should match the conference" do
        session = FactoryGirl.build(:session, :conference => Conference.first)
        session.should_not be_valid
        session.errors[:track_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    context "audience level" do
      it "should match the conference" do
        session = FactoryGirl.build(:session, :conference => Conference.first)
        session.should_not be_valid
        session.errors[:audience_level_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    context "session type" do
      it "should match the conference" do
        session = FactoryGirl.build(:session, :conference => Conference.first)
        session.should_not be_valid
        session.errors[:session_type_id].should include(I18n.t("errors.messages.invalid"))
      end
    end

    context "mechanics" do
      it "should be present for workshops" do
        session = FactoryGirl.build(:session, :mechanics => nil)
        session.should be_valid
        session.session_type = SessionType.new(:title => 'session_types.workshop.title')
        session.should_not be_valid
        session.errors[:mechanics].should include(I18n.t("errors.messages.blank"))
      end

      it "should be present for hands on" do
        session = FactoryGirl.build(:session, :mechanics => nil)
        session.should be_valid
        session.session_type = SessionType.new(:title => 'session_types.hands_on.title')
        session.should_not be_valid
        session.errors[:mechanics].should include(I18n.t("errors.messages.blank"))
      end
    end

    context "second author" do
      before(:each) do
        @session = FactoryGirl.build(:session)
      end

      it "should be a valid user" do
        @session.second_author_username = 'invalid_username'
        @session.should_not be_valid
        @session.errors[:second_author_username].should include("não existe")
      end

      it "should not be the same as first author" do
        @session.second_author_username = @session.author.username
        @session.should_not be_valid
        @session.errors[:second_author_username].should include("não pode ser o mesmo autor")
      end

      it "should be author" do
        guest = FactoryGirl.create(:user)
        @session.second_author_username = guest.username
        @session.should_not be_valid
        @session.errors[:second_author_username].should include("usuário não possui perfil de autor completo")
      end
    end

    context "duration" do
      before(:each) do
        @session = FactoryGirl.build(:session)
      end

      it "should only have duration of 10 minutes for lightning talks" do
        @session.session_type.title = 'session_types.lightning_talk.title'
        @session.duration_mins = 10
        @session.should be_valid
        @session.duration_mins = 50
        @session.should_not be_valid
        @session.duration_mins = 110
        @session.should_not be_valid
      end

      it "should only allow duration of 50 minutes for talks" do
        @session.session_type.title = 'session_types.talk.title'
        @session.duration_mins = 50
        @session.should be_valid
        @session.duration_mins = 110
        @session.should_not be_valid
        @session.duration_mins = 10
        @session.should_not be_valid
      end

      it "should only have duration of 110 minutes for hands on" do
        @session.session_type.title = 'session_types.hands_on.title'
        @session.duration_mins = 10
        @session.should_not be_valid
        @session.duration_mins = 50
        @session.should_not be_valid
        @session.duration_mins = 110
        @session.should be_valid
      end
    end

    context "experience report" do
      before(:each) do
        @session = FactoryGirl.build(:session)
        @session.track.title = 'tracks.experience_reports.title'
      end

      it "should only have duration of 50 minutes for talks" do
        @session.session_type.title = 'session_types.talk.title'
        @session.duration_mins = 50
        @session.should be_valid
        @session.duration_mins = 110
        @session.should_not be_valid
      end

      it "should be talk or lightning talk" do
        @session.session_type.title = 'session_types.talk.title'
        @session.should be_valid
        @session.session_type.title = 'session_types.lightning_talk.title'
        @session.duration_mins = 10
        @session.should be_valid
        @session.session_type.title = 'session_types.workshop.title'
        @session.should_not be_valid
      end
    end

    it "should validate that author doesn't change" do
      session = FactoryGirl.create(:session)
      session.author_id = FactoryGirl.create(:user).id
      session.should_not be_valid
      session.errors[:author_id].should == ["não pode mudar"]
    end

    context "confirming attendance:" do
      it "should validate that author agreement was accepted on acceptance" do
        session = FactoryGirl.build(:session)
        session.reviewing
        session.tentatively_accept
        session.update_attributes(:state_event => 'accept', :author_agreement => false).should be_false
        session.errors[:author_agreement].should == ["deve ser aceito"]
      end

      it "should validate that author agreement was accepted on withdraw" do
        session = FactoryGirl.build(:session)
        session.reviewing
        session.tentatively_accept
        session.update_attributes(:state_event => 'reject', :author_agreement => false).should be_false
        session.errors[:author_agreement].should == ["deve ser aceito"]
      end
    end

  end

  context "named scopes" do
    xit {should have_scope(:for_conference, :with => '1').where('conference_id = 1') }

    xit {should have_scope(:for_user, :with => '3').where('author_id = 3 OR second_author_id = 3') }

    xit {should have_scope(:for_tracks, :with => [1, 2]).where('track_id IN (1, 2)') }

    xit {should have_scope(:with_incomplete_final_reviews).where('final_reviews_count < 3') }

    xit {should have_scope(:with_incomplete_early_reviews).where('final_reviews_count < 1') }

    context "for reviewer" do
      before(:each) do
        @reviewer = FactoryGirl.create(:reviewer)
        @user = @reviewer.user
        @conference = @reviewer.conference
        @track = @conference.tracks.first
        @audience_level = @conference.audience_levels.first

        @session = FactoryGirl.create(:session, :conference => @conference, :track => @track, :audience_level => @audience_level)
      end

      context "preferences" do
        it "if user has no preferences, no sessions to review" do
          Session.for_reviewer(@user, @conference).should be_empty
        end

        it "one preference" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          Session.for_reviewer(@user, @conference).should == [@session]
        end

        it "multiple preferences" do
          audience_level = @conference.audience_levels.second
          session = FactoryGirl.create(:session, :conference => @conference, :track => @track, :audience_level => audience_level)

          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => audience_level)

          (Session.for_reviewer(@user, @conference) - [session, @session]).should be_empty
        end
      end

      context "cancelled" do
        before(:each) do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
        end

        it "non-cancelled should be returned" do
          Session.for_reviewer(@user, @conference).should == [@session]
        end

        it "cancelled should not be returned" do
          @session.cancel
          Session.for_reviewer(@user, @conference).should be_empty
        end
      end

      context "author" do
        before(:each) do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
        end

        it "if reviewer is first author, should not be returned" do
          FactoryGirl.create(:reviewer, :user => @session.author)

          Session.for_reviewer(@session.author, @conference).should be_empty
        end

        it "if reviewer is second author, should not be returned" do
          second_author = FactoryGirl.create(:author)
          @session.update_attributes!(:second_author => second_author)

          Session.for_reviewer(second_author, @conference).should be_empty
        end
      end

      it "if already reviewed by user, it should not be returned" do
        FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
        FactoryGirl.create(:final_review, :session => @session, :reviewer => @user)
        Session.for_reviewer(@user, @conference).should == []
      end
    end

    context "with incomplete early reviews" do
      before(:each) do
        @reviewer = FactoryGirl.create(:reviewer)
        @user = @reviewer.user
        @conference = @reviewer.conference

        @session = FactoryGirl.create(:session, :conference => @conference, :created_at => @conference.presubmissions_deadline - 1.day)
        FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @session.track, :audience_level => @session.audience_level)
      end

      it "should return sessions without early reviews" do
        Session.incomplete_early_reviews_for(@conference).should == [@session]
      end

      it "should not return sessions already reviewed" do
        FactoryGirl.create(:early_review, :session => @session, :reviewer => @user)
        Session.incomplete_early_reviews_for(@conference).should == []
      end

      it "should return session created at the pre submissions deadline" do
        @session.update_attribute(:created_at, @conference.presubmissions_deadline)
        @session.save!
        Session.incomplete_early_reviews_for(@conference).should == [@session]
      end

      it "should not return sessions created after the pre submissions deadline" do
        @session.update_attribute(:created_at, @conference.presubmissions_deadline + 1.second)
        @session.save!
        Session.incomplete_early_reviews_for(@conference).should == []
      end
    end
  end

  it "should determine if it's lightning talk" do
    lightning_talk = SessionType.new(:title => 'session_types.lightning_talk.title')
    session = FactoryGirl.build(:session)
    session.should_not be_lightning_talk
    session.session_type = lightning_talk
    session.should be_lightning_talk
  end

  it "should determine if it's experience_report" do
    experience_report = Track.new(:title => 'tracks.experience_reports.title')
    session = FactoryGirl.build(:session)
    session.should_not be_experience_report
    session.track = experience_report
    session.should be_experience_report
  end

  it "should overide to_param with session title" do
    session = FactoryGirl.create(:session, :title => "refatoração e código limpo: na prática.")
    session.to_param.ends_with?("-refatoracao-e-codigo-limpo-na-pratica").should be_true

    session.title = nil
    session.to_param.ends_with?("-refatoracao-e-codigo-limpo-na-pratica").should be_false
  end

  context "authors" do
    it "should provide main author" do
      session = FactoryGirl.build(:session)
      session.authors.should == [session.author]
    end

    it "should provide second author if available" do
      user = FactoryGirl.build(:user)
      user.add_role(:author)
      session = FactoryGirl.build(:session, :second_author => user)
      session.authors.should == [session.author, user]
    end

    it "should be empty if no authors" do
      session = FactoryGirl.build(:session)
      session.author = nil
      session.authors.should be_empty
    end

    it "should state that first author is author" do
      user = FactoryGirl.build(:user)
      user.add_role(:author)

      session = FactoryGirl.build(:session, :author => user)
      session.is_author?(user).should be_true
      session.author = nil
      session.is_author?(user).should be_false
    end

    it "should state that second author is author" do
      user = FactoryGirl.build(:user)
      user.add_role(:author)

      session = FactoryGirl.build(:session, :second_author => user)
      session.is_author?(user).should be_true
      session.second_author = nil
      session.is_author?(user).should be_false
    end
  end

  context "state machine" do
    before(:each) do
      @session = FactoryGirl.build(:session)
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

      it "should allow rejecting" do
        @session.reject.should be_true
        @session.should_not be_in_review
        @session.should be_rejected
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

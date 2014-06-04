# encoding: UTF-8
require 'spec_helper'

describe Session, type: :model do
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
    it { should allow_mass_assignment_of :language }

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
    it { should have_many :votes }

    context "second author username" do
      subject { FactoryGirl.build(:session) }
      it_should_behave_like "virtual username attribute", :second_author
    end
  end

  context "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :summary }
    it { should validate_presence_of :description }
    it { should validate_presence_of :benefits }
    it { should validate_presence_of :target_audience }
    it { should validate_presence_of :experience }
    it { should validate_presence_of :duration_mins }
    it { should validate_presence_of :keyword_list }
    it { should validate_presence_of :language }
    it { should validate_presence_of :track_id }
    it { should validate_presence_of :session_type_id }
    it { should validate_presence_of :audience_level_id }

    it { should ensure_inclusion_of(:language).in_array(['en', 'pt']) }

    should_validate_existence_of :conference, :author, :track, :session_type, :audience_level

    it { should validate_numericality_of :audience_limit }

    it { should ensure_length_of(:title).is_at_most(100) }
    it { should ensure_length_of(:target_audience).is_at_most(200) }
    it { should ensure_length_of(:summary).is_at_most(800) }
    it { should ensure_length_of(:description).is_at_most(2400) }
    it { should ensure_length_of(:benefits).is_at_most(400) }
    it { should ensure_length_of(:experience).is_at_most(400) }

    context "track" do
      it "should match the conference" do
        session = FactoryGirl.build(:session, :conference => Conference.first, :track => Conference.current.tracks.first)
        session.should_not be_valid
        session.errors[:track_id].should include(I18n.t("errors.messages.same_conference"))
      end
    end

    context "audience level" do
      it "should match the conference" do
        session = FactoryGirl.build(:session, :conference => Conference.first, :audience_level => Conference.current.audience_levels.first)
        session.should_not be_valid
        session.errors[:audience_level_id].should include(I18n.t("errors.messages.same_conference"))
      end
    end

    context "session type" do
      it "should match the conference" do
        session = FactoryGirl.build(:session, :conference => Conference.first, :session_type => Conference.current.session_types.first)
        session.should_not be_valid
        session.errors[:session_type_id].should include(I18n.t("errors.messages.same_conference"))
      end
    end

    context "mechanics" do
      context "workshops" do
        subject { FactoryGirl.build(:session) }
        before { subject.session_type = FactoryGirl.build(:session_type, :title => 'session_types.workshop.title') }

        it { should validate_presence_of(:mechanics) }
        it { should ensure_length_of(:mechanics).is_at_most(2400) }
      end

      context "hands on" do
        subject { FactoryGirl.build(:session) }
        before { subject.session_type = FactoryGirl.build(:session_type, :title => 'session_types.hands_on.title') }

        it { should validate_presence_of(:mechanics) }
        it { should ensure_length_of(:mechanics).is_at_most(2400) }
      end
    end

    context "second author" do
      before(:each) do
        @session = FactoryGirl.build(:session)
      end

      it "should be a valid user" do
        @session.second_author_username = 'invalid_username'
        @session.should_not be_valid
        @session.errors[:second_author_username].should include(I18n.t("activerecord.errors.messages.existence"))
      end

      it "should not be the same as first author" do
        @session.second_author_username = @session.author.username
        @session.should_not be_valid
        @session.errors[:second_author_username].should include(I18n.t("errors.messages.same_author"))
      end

      it "should be author" do
        guest = FactoryGirl.create(:user)
        @session.second_author_username = guest.username
        @session.should_not be_valid
        @session.errors[:second_author_username].should include(I18n.t("errors.messages.incomplete"))
      end
    end

    it "should only accept valid durations for session type" do
      @session = FactoryGirl.build(:session)
      @session.session_type.valid_durations = [25, 50]
      @session.duration_mins = 25
      @session.should be_valid
      @session.duration_mins = 50
      @session.should be_valid
      @session.duration_mins = 80
      @session.should_not be_valid
      @session.duration_mins = 110
      @session.should_not be_valid
    end

    it "should validate that author doesn't change" do
      session = FactoryGirl.create(:session)
      session.author_id = FactoryGirl.create(:user).id
      session.should_not be_valid
      session.errors[:author_id].should include(I18n.t("errors.messages.constant"))
    end

    context "confirming attendance:" do
      it "should validate that author agreement was accepted on acceptance" do
        session = FactoryGirl.build(:session)
        session.reviewing
        session.tentatively_accept
        session.update_attributes(:state_event => 'accept', :author_agreement => false).should be false
        session.errors[:author_agreement].should include(I18n.t("errors.messages.accepted"))
      end

      it "should validate that author agreement was accepted on withdraw" do
        session = FactoryGirl.build(:session)
        session.reviewing
        session.tentatively_accept
        session.update_attributes(:state_event => 'reject', :author_agreement => false).should be false
        session.errors[:author_agreement].should include(I18n.t("errors.messages.accepted"))
      end
    end

    it "should validate that there are a maximum of 10 keywords" do
      session = FactoryGirl.build(:session, :keyword_list => %w[a b c d e f g h i j])
      session.should be_valid
      session.keyword_list = %w[a b c d e f g h i j k]
      session.should_not be_valid
      session.errors[:keyword_list].should include(I18n.t("activerecord.errors.models.session.attributes.keyword_list.too_long", :count => 10))
    end

    it "should validate that there are a maximum of 10 keywords in comma-separated list" do
      session = FactoryGirl.build(:session, :keyword_list => "a, b, c, d, e, f, g, h, i, j")
      session.should be_valid
      session.keyword_list = "a, b, c, d, e, f, g, h, i, j, k"
      session.should_not be_valid
      session.errors[:keyword_list].should include(I18n.t("activerecord.errors.models.session.attributes.keyword_list.too_long", :count => 10))
    end
  end

  context "named scopes" do
    context "for_reviewer / for_review_in" do
      before(:each) do
        # TODO: review this
        @reviewer = FactoryGirl.create(:reviewer)
        @user = @reviewer.user
        @conference = @reviewer.conference
        @track = @conference.tracks.first
        @audience_level = @conference.audience_levels.first

        @conference.presubmissions_deadline = DateTime.now
        @session = FactoryGirl.create(:session, :conference => @conference, :track => @track, :audience_level => @audience_level, :created_at => @conference.presubmissions_deadline - 1.day)
      end

      context "during early review phase" do
        before(:each) do
          @conference.stubs(:in_early_review_phase?).returns(true)
          @conference.stubs(:in_final_review_phase?).returns(false)
        end

        it "if reviewed multiple times, it should only be returned once" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:early_review, :session => @session)
          FactoryGirl.create(:early_review, :session => @session)
          Session.for_reviewer(@user, @conference).should == [@session]
        end

        it "if already reviewed by user, it should not be returned" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:early_review, :session => @session, :reviewer => @user)
          Session.for_reviewer(@user, @conference).should == []
        end

        context "early review deadline" do
          it "if submitted at the early review deadline, it should be returned" do
            FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
            session = FactoryGirl.create(:session, :conference => @conference, :track => @track, :audience_level => @audience_level, :created_at => @conference.presubmissions_deadline)
            Session.for_reviewer(@user, @conference).should include(session)
          end

          it "if submitted 3 hours past the early review deadline, it should be returned" do
            FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
            session = FactoryGirl.create(:session, :conference => @conference, :track => @track, :audience_level => @audience_level, :created_at => @conference.presubmissions_deadline + 3.hours)
            Session.for_reviewer(@user, @conference).should include(session)
          end

          it "if submitted after 3 hours past the early review deadline, it should not be returned" do
            FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
            session = FactoryGirl.create(:session, :conference => @conference, :track => @track, :audience_level => @audience_level, :created_at => @conference.presubmissions_deadline + 3.hours + 1.second)
            Session.for_reviewer(@user, @conference).should_not include(session)
          end
        end
      end

      context "during final review phase" do
        before(:each) do
          @conference.stubs(:in_early_review_phase?).returns(false)
          @conference.stubs(:in_final_review_phase?).returns(true)
        end

        it "if reviewed multiple times, it should only be returned once" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:final_review, :session => @session)
          FactoryGirl.create(:final_review, :session => @session)
          Session.for_reviewer(@user, @conference).should == [@session]
        end

        it "if already reviewed by user, it should not be returned" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:final_review, :session => @session, :reviewer => @user)
          Session.for_reviewer(@user, @conference).should == []
        end

        it "if already reviewed by user and another user, it should not be returned" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:final_review, :session => @session)
          FactoryGirl.create(:final_review, :session => @session, :reviewer => @user)
          Session.for_reviewer(@user, @conference).should == []
        end

        it "if reviewed by user during early review, it should be returned" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create(:early_review, :session => @session, :reviewer => @user)
          Session.for_reviewer(@user, @conference).should == [@session]
        end

        it "if already reviewed 3 times, it should not be returned" do
          FactoryGirl.create(:preference, :reviewer => @reviewer, :track => @track, :audience_level => @audience_level)
          FactoryGirl.create_list(:final_review, 3, :session => @session)
          Session.for_reviewer(@user, @conference).should == []
        end
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
          @session.update_attributes!(:second_author_username => second_author.username)

          Session.for_reviewer(second_author, @conference).should be_empty
        end
      end
    end
  end

  SessionType.all_titles.each do |title|
    it "should determine if it's #{title}" do
      session = FactoryGirl.build(:session)
      session.session_type.title = "session_types.#{title}.title"
      session.send(:"#{title}?").should be true
      session.session_type.title = "session_types.other.title"
      session.send(:"#{title}?").should be false
    end
  end

  it "should overide to_param with session title" do
    session = FactoryGirl.create(:session, :title => "refatoração e código limpo: na prática.")
    session.to_param.ends_with?("-refatoracao-e-codigo-limpo-na-pratica").should be true

    session.title = nil
    session.to_param.ends_with?("-refatoracao-e-codigo-limpo-na-pratica").should be false
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
      session.is_author?(user).should be true
      session.author = nil
      session.is_author?(user).should be false
    end

    it "should state that second author is author" do
      user = FactoryGirl.build(:user)
      user.add_role(:author)

      session = FactoryGirl.build(:session, :second_author => user)
      session.is_author?(user).should be true
      session.second_author = nil
      session.is_author?(user).should be false
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
        @session.reviewing.should be true
        @session.should_not be_created
        @session.should be_in_review
      end

      it "should allow cancel" do
        @session.cancel.should be true
        @session.should_not be_created
        @session.should be_cancelled
      end

      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be false
      end

      it "should not allow accepting" do
        @session.accept.should be false
      end

      it "should not allow rejecting" do
        @session.reject.should be false
      end
    end

    context "State: in review" do
      before(:each) do
        @session.reviewing
        @session.should be_in_review
      end

      it "should allow reviewing again" do
        @session.reviewing.should be true
        @session.should be_in_review
      end

      it "should allow cancel" do
        @session.cancel.should be true
        @session.should_not be_in_review
        @session.should be_cancelled
      end

      it "should allow tentatively accept" do
        @session.tentatively_accept.should be true
        @session.should_not be_in_review
        @session.should be_pending_confirmation
      end

      it "should not allow accepting" do
        @session.accept.should be false
      end

      it "should allow rejecting" do
        @session.reject.should be true
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
        @session.reviewing.should be false
      end

      it "should not allow cancelling" do
        @session.cancel.should be false
      end

      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be false
      end

      it "should not allow accepting" do
        @session.accept.should be false
      end

      it "should not allow rejecting" do
        @session.reject.should be false
      end
    end

    context "State: pending confirmation" do
      before(:each) do
        @session.reviewing
        @session.tentatively_accept
        @session.should be_pending_confirmation
      end

      it "should not allow reviewing" do
        @session.reviewing.should be false
      end

      it "should not allow cancelling" do
        @session.cancel.should be false
      end

      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be false
      end

      it "should allow accepting" do
        @session.accept.should be true
        @session.should_not be_pending_confirmation
        @session.should be_accepted
      end

      it "should allow rejecting" do
        @session.reject.should be true
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
        @session.reviewing.should be false
      end

      it "should not allow cancelling" do
        @session.cancel.should be false
      end

      it "should not allow tentatively accept" do
        @session.tentatively_accept.should be false
      end

      it "should not allow accepting" do
        @session.accept.should be false
      end

      it "should not allow rejecting" do
        @session.reject.should be false
      end
    end

    context "State: rejected" do
      before(:each) do
        @session.reviewing
        @session.reject
        @session.should be_rejected
      end

      it "should not allow reviewing" do
        @session.reviewing.should be false
      end

      it "should not allow cancelling" do
        @session.cancel.should be false
      end

      it "should allow tentatively accept" do
        @session.tentatively_accept.should be true
        @session.should_not be_rejected
        @session.should be_pending_confirmation
      end

      it "should not allow accepting" do
        @session.accept.should be false
      end

      it "should not allow rejecting" do
        @session.reject.should be false
      end
    end
  end
end

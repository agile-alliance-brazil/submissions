# frozen_string_literal: true

require 'spec_helper'

describe Reviewer, type: :model do
  let(:conference) { FactoryBot.build(:conference) }
  let(:track) { FactoryBot.create(:track, conference: conference) }
  let(:audience_level) { FactoryBot.create(:audience_level, conference: conference) }

  before do
    EmailNotifications.stubs(:reviewer_invitation).returns(stub(deliver_now: true))
    # TODO: Improve outcome and conference usage
    Conference.stubs(:current).returns(conference)
    conference.save!
    track.save!
    audience_level.save!
  end

  it_should_trim_attributes Reviewer, :user_username

  describe 'validations' do
    it { is_expected.to validate_presence_of :conference_id }

    describe 'uniqueness' do
      before { FactoryBot.create(:reviewer, conference: conference) }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:conference_id) }
    end

    should_validate_existence_of :conference, :user

    it 'validates that at least 1 preference was accepted' do
      reviewer = FactoryBot.create(:reviewer, conference: conference)
      reviewer.preferences.build(accepted: false)
      expect(reviewer.accept).to be false
      expect(reviewer.errors[:base]).to include(I18n.t('activerecord.errors.models.reviewer.preferences'))
    end

    it 'validates that reviewer agreement was accepted' do
      reviewer = FactoryBot.create(:reviewer, reviewer_agreement: false, conference: conference)
      reviewer.preferences.build(accepted: true, track_id: 1, audience_level_id: 1)
      expect(reviewer.accept).to be false
      expect(reviewer.errors[:reviewer_agreement]).to include(I18n.t('errors.messages.accepted'))
    end

    it 'copies user errors to user_username' do
      reviewer = FactoryBot.create(:reviewer, conference: conference)
      new_reviewer = FactoryBot.build(:reviewer, user: reviewer.user, conference: reviewer.conference)
      expect(new_reviewer).not_to be_valid
      expect(new_reviewer.errors[:user_username]).to include(I18n.t('activerecord.errors.messages.taken'))
    end

    context 'user' do
      before do
        @reviewer = FactoryBot.create(:reviewer, conference: conference)
      end

      it 'is a valid user' do
        @reviewer.user_username = 'invalid_username'
        expect(@reviewer).not_to be_valid
        expect(@reviewer.errors[:user_username]).to include(I18n.t('activerecord.errors.messages.existence'))
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :conference }
    it { is_expected.to have_many(:preferences).dependent(:destroy) }
    it { is_expected.to have_many(:accepted_preferences).class_name('Preference') }

    it { is_expected.to accept_nested_attributes_for :preferences }

    context 'reviewer username' do
      subject { FactoryBot.build(:reviewer, conference: conference) }

      it_behaves_like 'virtual username attribute', :user
    end

    context 'inferred' do
      before do
        @reviewer = FactoryBot.build(:reviewer, conference: conference)
      end

      it 'finds early reviews for this reviewer' do
        @reviewer.user.expects(:early_reviews).returns(Review)
        Review.expects(:for_conference).with(conference).returns(:result)

        expect(@reviewer.early_reviews).to eq(:result)
      end
      it 'finds final reviews for this reviewer' do
        @reviewer.user.expects(:final_reviews).returns(Review)
        Review.expects(:for_conference).with(conference).returns(:result)

        expect(@reviewer.final_reviews).to eq(:result)
      end
      it 'finds all reviews for this reviewer' do
        @reviewer.user.expects(:reviews).returns(Review)
        Review.expects(:for_conference).with(conference).returns(:result)

        expect(@reviewer.reviews).to eq(:result)
      end
    end
  end

  context 'state machine' do
    before do
      @reviewer = FactoryBot.build(:reviewer, conference: conference)
    end

    context 'State: created' do
      it 'is the initial state' do
        expect(@reviewer).to be_created
      end

      it 'allows invite' do
        expect(@reviewer.invite).to be true
        expect(@reviewer).not_to be_created
        expect(@reviewer).to be_invited
      end

      it 'does not allow accept' do
        expect(@reviewer.accept).to be false
      end

      it 'does not allow reject' do
        expect(@reviewer.reject).to be false
      end
    end

    context 'Event: invite' do
      it 'sends invitation email' do
        EmailNotifications.expects(:reviewer_invitation).with(@reviewer).returns(mock(deliver_now: true))
        @reviewer.invite
      end
    end

    context 'State: invited' do
      before do
        @reviewer.invite
        expect(@reviewer).to be_invited
      end

      it 'allows inviting again' do
        expect(@reviewer.invite).to be true
        expect(@reviewer).to be_invited
      end

      it 'allows accepting' do
        # TODO: review this
        @reviewer.preferences.build(accepted: true, track_id: track.id, audience_level_id: audience_level.id)
        expect(@reviewer.accept).to be true
        expect(@reviewer).not_to be_invited
        expect(@reviewer).to be_accepted
      end

      it 'allows rejecting' do
        expect(@reviewer.reject).to be true
        expect(@reviewer).not_to be_invited
        expect(@reviewer).to be_rejected
      end
    end

    context 'State: accepted' do
      before do
        @reviewer.invite
        # TODO: review this
        @reviewer.preferences.build(accepted: true, track_id: track.id, audience_level_id: audience_level.id)
        @reviewer.accept
        expect(@reviewer).to be_accepted
      end

      it 'does not allow invite' do
        expect(@reviewer.invite).to be false
      end

      it 'does not allow accepting' do
        expect(@reviewer.accept).to be false
      end

      it 'does not allow rejecting' do
        expect(@reviewer.reject).to be false
      end
    end

    context 'State: rejected' do
      before do
        @reviewer.invite
        @reviewer.reject
        expect(@reviewer).to be_rejected
      end

      it 'does not allow invite' do
        expect(@reviewer.invite).to be false
      end

      it 'does not allow accepting' do
        expect(@reviewer.accept).to be false
      end

      it 'does not allow rejecting' do
        expect(@reviewer.reject).to be false
      end
    end
  end

  describe 'callbacks' do
    it 'invites after created' do
      reviewer = FactoryBot.build(:reviewer)
      reviewer.save
      expect(reviewer).to be_invited
    end

    it 'does not invite if validation failed' do
      reviewer = FactoryBot.build(:reviewer, user_id: nil)
      reviewer.save
      expect(reviewer).not_to be_invited
    end
  end

  shared_examples_for 'reviewer role' do
    it 'makes given user reviewer role after invitation accepted' do
      reviewer = FactoryBot.create(:reviewer, user: user, conference: conference)
      reviewer.invite
      expect(user).not_to be_reviewer
    end

    it 'does not remove organizer role if more reviewers for user are available' do
      old_conference = FactoryBot.create(:conference, year: 1)
      old_track = FactoryBot.create(:track, conference: old_conference)
      old_audience_level = FactoryBot.create(:audience_level, conference: old_conference)
      accepted_reviewer_for(user, old_conference, old_track, old_audience_level)

      reviewer = accepted_reviewer_for(user, conference, track, audience_level)
      expect(user).to be_reviewer
      reviewer.destroy
      expect(user).not_to be_reviewer
      # TODO: Remove current_conference from reviewer check.
      # Stupid user class redefines the roles to user current conference
      expect(user).to be_reviewer_without_conference
      expect(user.reload).not_to be_reviewer
      expect(user.reload).to be_reviewer_without_conference
    end

    it 'removes organizer role after last reviewer for user is destroyed' do
      reviewer = accepted_reviewer_for(user, conference, track, audience_level)

      expect(user).to be_reviewer
      reviewer.destroy
      expect(user).not_to be_reviewer
      expect(user.reload).not_to be_reviewer
    end
  end

  context 'managing reviewer role for complete user' do
    let(:user) { FactoryBot.create(:user) }

    it_behaves_like 'reviewer role'
  end

  context 'managing reviewer role for simple user' do
    let(:user) { FactoryBot.create(:simple_user) }

    it_behaves_like 'reviewer role'
  end

  context 'checking if able to review a track' do
    subject(:reviewer) { FactoryBot.create(:reviewer, user: organizer.user, conference: conference) }

    let(:organizer) { FactoryBot.create(:organizer, track: track, conference: conference) }

    before do
      reviewer.save!
    end

    it 'can review track when not organizer' do
      expect(reviewer).to be_can_review(FactoryBot.create(:track, conference: conference))
    end

    it 'can not review track when organizer on the same conference' do
      expect(reviewer).not_to be_can_review(organizer.track)
    end

    it 'can review track when organizer for different conference' do
      other_conference = FactoryBot.create(:conference)
      reviewer = FactoryBot.create(:reviewer, user: organizer.user, conference: other_conference)
      expect(reviewer).to be_can_review(organizer.track)
    end
  end

  context 'display name rules' do
    let(:user) { FactoryBot.build(:user, first_name: 'Raphael', last_name: 'Molesim', default_locale: 'en') }

    context 'for signing reviewer' do
      subject(:reviewer) { FactoryBot.build(:reviewer, user: user, sign_reviews: true) }

      it 'displays reviewer name' do
        expect(reviewer.display_name).to eq('Raphael Molesim')
      end
    end

    context 'for non signing reviewer' do
      subject(:reviewer) { FactoryBot.build(:reviewer, user: user, sign_reviews: false) }

      it 'displays generic reviewer title' do
        expect(reviewer.display_name).to eq(I18n.t('formtastic.labels.reviewer.user_id'))
      end
      it 'displays generic reviewer title with index if passed' do
        expect(reviewer.display_name(1)).to eq("#{I18n.t('formtastic.labels.reviewer.user_id')} 1")
      end
    end
  end

  def accepted_reviewer_for(user, conference, track, audience_level)
    FactoryBot.create(:reviewer, user: user, conference: conference)
              .tap(&:invite)
              .tap { |r| r.preferences.build(accepted: true, track_id: track.id, audience_level_id: audience_level.id) }
              .tap(&:accept)
  end
end

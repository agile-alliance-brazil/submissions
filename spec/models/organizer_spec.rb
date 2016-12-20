# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe Organizer, type: :model do
  it_should_trim_attributes Organizer, :user_username

  context 'validations' do
    it { should validate_presence_of :track_id }

    context 'uniqueness' do
      before { FactoryGirl.create(:organizer) }
      it { should validate_uniqueness_of(:track_id).scoped_to(:conference_id, :user_id).with_message(I18n.t('activerecord.errors.models.organizer.attributes.track_id.taken')) }
    end

    should_validate_existence_of :user, :conference
    should_validate_existence_of :track

    context 'user' do
      it 'should be a valid user' do
        organizer = FactoryGirl.build(:organizer)
        organizer.user_username = 'invalid_username'
        expect(organizer).to_not be_valid
        expect(organizer.errors[:user_username]).to include(I18n.t('activerecord.errors.messages.existence'))
      end
    end

    context 'track' do
      it 'should match the conference' do
        track = FactoryGirl.create(:track)
        other_conference = FactoryGirl.create(:conference)
        organizer = FactoryGirl.build(:organizer, track: track, conference: other_conference)
        expect(organizer).to_not be_valid
        expect(organizer.errors[:track_id]).to include(I18n.t('errors.messages.same_conference'))
      end
    end
  end

  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :track }
    it { should belong_to :conference }

    context 'organizer username' do
      subject { FactoryGirl.build(:organizer) }
      it_should_behave_like 'virtual username attribute', :user
    end
  end

  shared_examples_for 'organizer role' do
    it 'should make given user organizer role after created' do
      expect(subject).to_not be_organizer

      FactoryGirl.create(:organizer, user: subject)

      expect(subject).to be_organizer
      expect(subject.reload).to be_organizer
    end

    it 'should remove organizer role after destroyed' do
      organizer = FactoryGirl.create(:organizer, user: subject)
      expect(subject).to be_organizer
      organizer.destroy
      expect(subject).to_not be_organizer
      expect(subject.reload).to_not be_organizer
    end

    it 'should keep organizer role after destroyed if user organizes other tracks' do
      other_organizer = FactoryGirl.create(:organizer, user: subject)
      track = FactoryGirl.create(:track, conference: other_organizer.conference)
      organizer = FactoryGirl.create(:organizer, user: subject, track: track, conference: other_organizer.conference)
      expect(subject).to be_organizer
      organizer.destroy
      expect(subject).to be_organizer
      expect(subject.reload).to be_organizer
    end

    it 'should remove organizer role after update' do
      organizer = FactoryGirl.create(:organizer, user: subject)
      another_user = FactoryGirl.create(:user)
      organizer.user = another_user
      organizer.save
      expect(subject.reload).to_not be_organizer
      expect(another_user).to be_organizer
    end

    it 'should keep organizer role after update if user organizes other tracks' do
      other_organizer = FactoryGirl.create(:organizer, user: subject)
      track = FactoryGirl.create(:track, conference: other_organizer.conference)
      organizer = FactoryGirl.create(:organizer, user: subject, track: track, conference: other_organizer.conference)
      another_user = FactoryGirl.create(:user)
      organizer.user = another_user
      organizer.save
      expect(subject.reload).to be_organizer
      expect(another_user).to be_organizer
    end
  end

  context 'managing organizer role for normal user' do
    subject { FactoryGirl.create(:user) }
    it_should_behave_like 'organizer role'
  end

  context 'managing organizer role for simple user' do
    subject { FactoryGirl.create(:simple_user) }
    it_should_behave_like 'organizer role'
  end
end

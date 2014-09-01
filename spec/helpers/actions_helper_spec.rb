require 'spec_helper'
require 'cancan/matchers'

describe ActionsHelper, type: :helper do
  before :each do
    @conference = Conference.current
    helper.stubs(:can?).returns(true)
  end
  describe 'user section' do
    context 'normal user logged in' do
      subject do
        helper.user_section_for(FactoryGirl.build(:user)).actions
      end

      it 'should be able to show user profile' do
        expect(subject[0][:name]).to eq(t('actions.profile'))
      end

      it 'should be able to edit user profile' do
        expect(subject[1][:name]).to eq(t('actions.edit_profile'))
      end

      it 'should be able to change password' do
        expect(subject[2][:name]).to eq(t('actions.change_password'))
      end

      it 'should be able to logout' do
        expect(subject[3][:name]).to eq('Logout')
      end
    end
  end
  describe 'reviewer section' do
    before :each do
      @user = FactoryGirl.build(:user)
      @conference.stubs(:in_final_review_phase?).returns(true)
      helper.stubs(:current_user).returns(@user)
    end
    context 'reviewer logged in' do
      subject do
        helper.reviewer_section_for(@user, @conference).actions
      end
      it 'should be able to view list of sessions to review' do
        Session.stubs(:for_reviewer => stub(:to_a => stub(:count => 0)))

        expect(subject[0][:name]).to eq(t('actions.reviewer_sessions', count: 0))
      end
      it 'should not view list of sessions to review out of review phase' do
        @conference.stubs(:in_early_review_phase?).returns(false)
        @conference.stubs(:in_final_review_phase?).returns(false)

        expect(subject[0][:name]).to_not eq(t('actions.reviewer_sessions', count: 0))
      end
      it 'should be able to view how many sessions are left to review' do
        Session.stubs(:for_reviewer => stub(:to_a => stub(:count => 3)))

        actions = helper.reviewer_section_for(@user, @conference).actions

        expect(actions[0][:name]).to eq(t('actions.reviewer_sessions', count: 3))
      end
      it 'should be able to view reviews it created' do
        expect(subject[1][:name]).to eq(t('actions.reviewer_reviews', count: 0))
      end
      it 'should be able to view how many reviews it created' do
        @user.stubs(:reviews).returns(stub(:for_conference => stub(:count => 2)))

        actions = helper.reviewer_section_for(@user, @conference).actions

        expect(actions[1][:name]).to eq(t('actions.reviewer_reviews', count: 2))
      end
      it 'should be able to review the session when looking at it' do
        helper.instance_variable_set(:@session, FactoryGirl.build(:session))

        expect(subject[2][:name]).to eq(t('actions.review_session'))
      end
    end
  end
  describe 'session section' do
    before :each do
      @user = FactoryGirl.build(:user)
      helper.stubs(:current_user).returns(@user)
    end
    context 'normal user logged in' do
      subject do
        helper.session_section_for(@user, @conference).actions
      end
      it 'should be able to submit proposal' do
        expect(subject[0][:name]).to eq(t('actions.submit_session'))
      end
      it 'should be able to browse sessions' do
        expect(subject[1][:name]).to eq(t('actions.browse_sessions', count: 0))
      end
      it 'should be able to browse sessions with count' do
        Session.stubs(:for_conference => stub(:count => 2))

        actions = helper.session_section_for(@user, @conference).actions

        expect(actions[1][:name]).to eq(t('actions.browse_sessions', count: 2))
      end
      it 'should be able to view its own sessions' do
        @user.stubs(:sessions_for_conference).returns(stub(:count => 1))

        expect(subject[2][:name]).to eq(t('actions.my_sessions'))
      end
    end
  end
end

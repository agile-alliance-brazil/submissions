# frozen_string_literal: true

require 'spec_helper'

describe SessionFilter, type: :model do
  it_behaves_like 'ActiveModel'

  describe 'filtering by user' do
    subject(:filter) { SessionFilter.new }

    let(:user) { FactoryBot.build(:user, id: 1) }

    context 'with param user_id' do
      subject(:filter) { SessionFilter.new(nil, '1') }

      its(:user_id) { is_expected.to eq('1') }

      it 'provides username reader' do
        User.expects(:find).with('1').returns(user)

        expect(filter.username).to eq(user.username)
      end
    end

    context 'without param user_id' do
      its(:user_id) { is_expected.to be_nil }
      its(:username) { is_expected.to be_nil }
    end

    context 'with param username' do
      subject { SessionFilter.new(username: 'dtsato') }

      before do
        User.stubs(:find_by).with(username: 'dtsato').returns(user)
      end

      its(:user_id) { is_expected.to eq(1) }
    end

    context 'without param username' do
      its(:user_id) { is_expected.to be_nil }
      its(:username) { is_expected.to be_nil }
    end

    it 'provides username writer' do
      User.expects(:find_by).twice.with(username: user.username).returns(user)

      filter.username = user.username
      expect(filter.user_id).to eq(1)

      filter.username = "  #{user.username}  "
      expect(filter.user_id).to eq(1)
    end

    it 'username writer should not fail when invalid username' do
      User.expects(:find_by).with(username: 'dansato').returns(nil)

      filter.username = 'dansato'
      expect(filter.user_id).to be_nil

      filter.username = ''
      expect(filter.user_id).to be_nil
    end
  end

  {
    'tag' => :tags,
    'track' => :track_id,
    'audience level' => :audience_level_id,
    'session type' => :session_type_id,
    'state' => :state
  }.each do |filter, filter_param|
    describe "filtering by #{filter}" do
      context "with param #{filter_param}" do
        subject { SessionFilter.new(filter_param => 'filter_value') }

        its(filter_param) { is_expected.to eq('filter_value') }
      end

      context "without param #{filter_param}" do
        subject { SessionFilter.new({}) }

        its(filter_param) { is_expected.to be_nil }
      end
    end
  end

  describe 'apply scopes' do
    let(:scope) { mock('scope') }

    it 'applies user scope when user_id is present' do
      scope.expects(:for_user).with(1)

      filter = SessionFilter.new({}, 1)
      filter.apply(scope)
    end

    {
      tags: :tagged_with,
      track_id: :for_tracks,
      audience_level_id: :for_audience_level,
      session_type_id: :for_session_type
    }.each do |filter_param, named_scope|
      it "should apply #{named_scope} scope when #{filter_param} is present" do
        scope.expects(named_scope).with('filter_value')

        filter = SessionFilter.new(filter_param => 'filter_value')
        filter.apply(scope)
      end
    end

    it 'applies with_state scope when state is present' do
      scope.expects(:with_state).with(:filter_value)

      filter = SessionFilter.new(state: 'filter_value')
      filter.apply(scope)
    end

    it 'combines scopes' do
      scope.expects(:tagged_with).with('tag1, tag2').returns(scope)
      scope.expects(:for_tracks).with('1').returns(scope)
      scope.expects(:for_user).with(1).returns(scope)

      filter = SessionFilter.new({ tags: 'tag1, tag2', track_id: '1' }, 1)
      filter.apply(scope)
    end
  end
end

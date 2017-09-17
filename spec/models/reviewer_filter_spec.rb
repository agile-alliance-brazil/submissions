# frozen_string_literal: true

require 'spec_helper'

describe ReviewerFilter, type: :model do
  it_should_behave_like 'ActiveModel'

  describe 'filtering by state' do
    context 'with param state' do
      subject { ReviewerFilter.new(reviewer_filter: { state: 'active' }) }

      its(:state) { should == 'active' }
    end

    context 'without param state' do
      subject { ReviewerFilter.new(reviewer_filter: {}) }

      its(:state) { should be_nil }
    end
  end

  describe 'filtering by track' do
    context 'with param track_id' do
      subject { ReviewerFilter.new(reviewer_filter: { track_id: 8 }) }

      its(:track_id) { should == 8 }
    end

    context 'without param track_id' do
      subject { ReviewerFilter.new(reviewer_filter: {}) }

      its(:track_id) { should be_nil }
    end
  end

  describe 'apply scopes' do
    it 'should apply state scope when state is present' do
      scope = mock('scope')
      scope.expects(:with_state).with(:accepted)

      filter = ReviewerFilter.new(reviewer_filter: { state: 'accepted' })
      filter.apply(scope)
    end

    it 'should apply track scope when track_id is present' do
      scope = mock('scope')
      scope.expects(:for_track).with('1')

      filter = ReviewerFilter.new(reviewer_filter: { track_id: '1' })
      filter.apply(scope)
    end

    it 'should combine scopes' do
      scope = mock('scope')
      scope.expects(:for_track).with('1').returns(scope)
      scope.expects(:with_state).with(:inactive).returns(scope)

      filter = ReviewerFilter.new(reviewer_filter: { state: 'inactive', track_id: '1' })
      filter.apply(scope)
    end
  end
end

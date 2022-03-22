# frozen_string_literal: true

require 'spec_helper'

describe 'ApplicationController' do
  describe '#authorize_action' do
    context 'controller with a model class' do
      it 'passes the class type to autorize! method' do
        controller = CommentsController.new
        controller.stubs(:params).returns(action: 'create')
        controller.expects(:authorize!).with(:create, Comment)
        controller.send(:authorize_action)
      end
    end

    context 'controller without a model class' do
      it 'passes the class type to autorize! method' do
        controller = OrganizerSessionsController.new
        controller.stubs(:params).returns(action: 'index')
        controller.expects(:authorize!).with(:index, 'organizer_sessions')
        controller.send(:authorize_action)
      end
    end
  end

  describe '#current_ability' do
    let(:controller) { ApplicationController.new }

    let(:session_id) { 'the-session-id' }
    let(:session) { Session.new }
    let(:reviewer_id) { 'the-reviewer-id' }
    let(:reviewer) { Reviewer.new }

    before do
      controller.stubs(:params).returns(session_id: session_id, reviewer_id: reviewer_id)
      controller.stubs(:current_user).returns(User.new)
    end

    context 'when current ability is not set' do
      it 'load session and reviewer from database' do
        Session.expects(:find).times(1).with(session_id).returns(session)
        Reviewer.expects(:find).times(1).with(reviewer_id).returns(reviewer)
        current_ability = controller.current_ability
        expect(current_ability.session).to equal(session)
        expect(current_ability.reviewer).to equal(reviewer)
      end
    end

    context 'when current ability is set' do
      it 'load session and reviewer from database' do
        Session.expects(:find).times(1).with(session_id).returns(session)
        Reviewer.expects(:find).times(1).with(reviewer_id).returns(reviewer)
        controller.current_ability
        controller.current_ability
      end
    end
  end
end

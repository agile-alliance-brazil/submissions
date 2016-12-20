# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe 'ApplicationController' do
  describe '#authorize_action' do
    context 'controller with a model class' do
      it 'should pass the class type to autorize! method' do
        controller = CommentsController.new
        controller.stubs(:params).returns(action: 'create')
        controller.expects(:authorize!).with(:create, Comment)
        controller.send(:authorize_action)
      end
    end

    context 'controller without a model class' do
      it 'should pass the class type to autorize! method' do
        controller = OrganizerSessionsController.new
        controller.stubs(:params).returns(action: 'index')
        controller.expects(:authorize!).with(:index, 'organizer_sessions')
        controller.send(:authorize_action)
      end
    end
  end
end

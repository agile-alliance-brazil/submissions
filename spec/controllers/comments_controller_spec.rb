# encoding: UTF-8
# frozen_string_literal: true
require 'spec_helper'

describe CommentsController, type: :controller do
  render_views

  it_should_require_login_for_actions :index, :show, :create, :edit, :update, :destroy
  let(:session) { FactoryGirl.create(:session) }
  let(:valid_comment_params) do
    { comment: 'Super comment!' }
  end
  subject { FactoryGirl.create(:comment, commentable: session) }
  before(:each) do
    sign_in subject.user
    disable_authorization
    EmailNotifications.stubs(:comment_submitted).returns(stub(deliver_now: true))
  end

  it 'index action should redirect to session path' do
    get :index, session_id: session.id

    path = session_url(session.conference, session, anchor: 'comments')
    expect(response).to redirect_to(path)
  end

  it 'show action should redirect to edit path' do
    get :show, session_id: session.id, id: subject.id

    path = edit_session_comment_url(session.conference, session, subject)
    expect(response).to redirect_to(path)
  end

  it 'create action should render new template when model is invalid' do
    post :create, session_id: session.id, comment: { comment: nil }

    expect(response).to render_template('sessions/show')
  end

  it 'create action should redirect when model is valid' do
    post :create, session_id: session.id, comment: valid_comment_params

    path = session_url(session.conference, session, anchor: 'comments')
    expect(response).to redirect_to(path)
  end

  it 'create action should send an email when model is valid' do
    EmailNotifications.expects(:comment_submitted).returns(mock(deliver_now: true))

    post :create, session_id: session.id, comment: valid_comment_params
  end

  it 'edit action should render edit template' do
    get :edit, session_id: session.id, id: subject.id

    expect(response).to render_template(:edit)
  end

  it 'update action should render edit template when model is invalid' do
    patch :update, session_id: session.id, id: subject.id, comment: { comment: nil }

    expect(assigns(:session).id).to eq(session.id)
    expect(response).to render_template(:edit)
  end

  it 'update action should redirect when model is valid' do
    patch :update, session_id: session.id, id: subject.id, comment: valid_comment_params

    path = session_path(session.conference, session, anchor: 'comments')
    expect(response).to redirect_to(path)
  end

  it 'delete action should redirect to session' do
    delete :destroy, session_id: session.id, id: subject.id

    path = session_path(session.conference, session, anchor: 'comments')
    expect(response).to redirect_to(path)
  end
end

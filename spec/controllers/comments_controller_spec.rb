# encoding: UTF-8
require 'spec_helper'

describe CommentsController, type: :controller do
  render_views

  it_should_require_login_for_actions :index, :show, :create, :edit, :update, :destroy

  before(:each) do
    @comment = FactoryGirl.create(:comment)
    sign_in @comment.user
    disable_authorization
    EmailNotifications.stubs(:comment_submitted).returns(stub(:deliver => true))
  end

  it "index action should redirect to session path" do
    get :index, :session_id => @comment.commentable
    response.should redirect_to(session_url(@comment.commentable.conference, @comment.commentable, :anchor => 'comments'))
  end

  it "show action should redirect to edit path" do
    get :show, :session_id => @comment.commentable, :id => @comment.id
    response.should redirect_to(edit_session_comment_url(@comment.commentable.conference, @comment.commentable, @comment))
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :session_id => @comment.commentable, :comment => {}
    response.should render_template('sessions/show')
  end

  it "create action should redirect when model is valid" do
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, :session_id => @comment.commentable
    response.should redirect_to(session_url(@comment.commentable.conference, @comment.commentable, :anchor => 'comments'))
  end

  it "create action should send an email when model is valid" do
    Comment.any_instance.stubs(:valid?).returns(true)
    EmailNotifications.expects(:comment_submitted).returns(mock(:deliver => true))
    post :create, :session_id => @comment.commentable
  end

  it "edit action should render edit template" do
    get :edit, :session_id => @comment.commentable, :id => Comment.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    put :update, :id => Comment.first, :session_id => @comment.commentable, :comment => {:comment => nil}
    assigns(:session).should == @comment.commentable
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    put :update, :id => Comment.first, :session_id => @comment.commentable
    response.should redirect_to(session_path(@comment.commentable.conference, @comment.commentable, :anchor => 'comments'))
  end

  it "delete action should redirect to session" do
    delete :destroy, :id => Comment.first, :session_id => @comment.commentable
    response.should redirect_to(session_path(@comment.commentable.conference, @comment.commentable, :anchor => 'comments'))
  end
end

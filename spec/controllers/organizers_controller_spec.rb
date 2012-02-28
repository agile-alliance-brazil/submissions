# encoding: UTF-8
require 'spec_helper'
 
describe OrganizersController do
  render_views

  it_should_require_login_for_actions :index, :new, :create, :edit, :update, :destroy

  before(:each) do
    @user ||= FactoryGirl.create(:user)
    sign_in @user
    disable_authorization
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
  it "new action should only load conference tracks" do
    get :new
    (assigns(:tracks) - Track.for_conference(Conference.current)).should be_empty
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, :organizer => {}
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    user = FactoryGirl.create(:user)
    track = FactoryGirl.create(:track)
    post :create, :organizer => {:user_username => user.username, :track_id => track.id, :conference_id => track.conference_id}
    response.should redirect_to(organizers_path(Conference.current))
  end

  it "edit action should only load conference tracks" do
    organizer = FactoryGirl.create(:organizer, :user_id => @user.id)
    get :edit, :id => organizer.id
    (assigns(:tracks) - Track.for_conference(Conference.current)).should be_empty
  end
  
  it "update action should render edit template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    organizer = FactoryGirl.create(:organizer, :user_id => @user.id)
    post :update, :id => organizer.id, :organizer => { :track_id => nil }
    response.should render_template(:edit)
  end
  
  it "update action should redirect when model is valid" do
    organizer = FactoryGirl.create(:organizer, :user_id => @user.id)
    post :update, :id => organizer.id
    response.should redirect_to(organizers_path(Conference.current))
  end
  
  it "destroy action should redirect" do
    organizer = FactoryGirl.create(:organizer, :user_id => @user.id)
    delete :destroy, :id => organizer.id
    response.should redirect_to(organizers_path(Conference.current))
  end
end

# encoding: UTF-8
require 'spec_helper'

describe RegistrationsController, type: :controller do
  render_views
  it_should_behave_like_a_devise_controller

  before(:each) do
    @user ||= FactoryGirl.create(:user)
    # TODO: Remove conference dependency
    FactoryGirl.create(:conference)
    EmailNotifications.stubs(:welcome).returns(stub(deliver_now: true))
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "new action should build user with default locale" do
    get :new, locale: 'en'
    expect(assigns(:user).default_locale.to_sym).to eq(:en)
  end

  it "create action should render new template when model is invalid" do
    # +stubs(:valid?).returns(false)+ doesn't work here because
    # inherited_resources does +obj.errors.empty?+ to determine
    # if validation failed
    post :create, user: {}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    User.any_instance.stubs(:valid?).returns(true)
    post :create
    expect(response).to redirect_to(root_url)
  end

  it "create action should login new user" do
    User.any_instance.stubs(:valid?).returns(true)
    post :create
    expect(controller.current_user).to_not be_nil
  end

  it "create action should send welcome e-mail" do
    EmailNotifications.expects(:welcome).returns(mock(deliver_now: true))
    User.any_instance.stubs(:valid?).returns(true)
    post :create
  end

  context "logged in" do
    before(:each) do
      sign_in @user
      disable_authorization
    end

    it "edit action should render edit template" do
      get :edit
      expect(response).to render_template(:edit)
    end

    it "edit action should set default locale regardless of params" do
      get :edit, locale: 'en'
      expect(assigns(:user).default_locale.to_sym).to eq(:'pt-BR')
    end

    it "update action should render edit template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      patch :update, user: { username: nil }
      expect(response).to render_template(:edit)
    end

    # it "update action should render change password" do
    #   patch :update, user: {password: nil}
    #   expect(response).to render_template(:edit)
    #   expect(assigns(:update_password)).to eq("true")
    # end

    it "update action should redirect when model is valid" do
      patch :update, user: {
        current_password: 'secret',
        password: 'new',
        password_confirmation: 'new'
      }
      expect(response).to redirect_to(user_path(assigns(:user)))
    end
  end

end

# encoding: UTF-8
require 'spec_helper'

describe UsersController, type: :controller do
  fixtures :users
  render_views

  # TODO: Shouldn't need a conference to render
  before(:each) do
    @conference = FactoryGirl.create(:conference)
  end

  it "show should work" do
    get :show, id: User.first
  end
end

describe UsersController, type: :controller do
  fixtures :users

  describe "#index" do
    describe "with javascript format" do
      before do
        xhr :get, :index, format: :js, term: 'dt'
      end

      subject { response }

      its(:content_type) { should == "text/javascript" }
    end

    describe "with html format" do
      before do
        get :index
      end

      it { should redirect_to(new_user_registration_path) }
    end
  end

  describe "#show" do
    before do
      get :show, id: User.first
    end

    it { should respond_with(:success) }
    it { should render_template(:show) }
  end
end
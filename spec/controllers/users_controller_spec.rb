# encoding: UTF-8
require 'spec_helper'

describe UsersController, :render_views => true do
  render_views
  
  it "show should work" do
    get :show, :id => User.first
  end
end

describe UsersController do
  describe "#index" do
    describe "with javascript format" do
      before do
        get :index, :format => :js, :term => 'dt'
      end
      
      it { should respond_with_content_type(:js) }
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
      get :show, :id => User.first
    end
    
    it { should respond_with(:success) }
    it { should render_template(:show) }
  end
end
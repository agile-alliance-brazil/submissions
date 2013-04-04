#encoding:utf-8
require 'spec_helper'

describe VotesController, :render_views => true do
  render_views

  it "show should work" do
    get :index
  end
end

describe VotesController do

  it_should_require_login_for_actions :index, :create, :destroy

  before(:each) do
    @vote ||= FactoryGirl.create(:vote)
    sign_in @vote.user
    disable_authorization
  end

  describe "#index" do
    before do
      get :index
    end

    it { should assign_to(:sessions).with([@vote.session]) }
  end

  describe "#create" do
    before do
      @session = FactoryGirl.create(:session)
      post :create, :vote => {:session_id => @session.id}
    end

    xit { should respond_with(:redirect) }
    xit { @session.votes.should_not be_empty }
  end

  describe "#destroy" do
    before do
      delete :destroy, :id => @vote.id
    end

    it { should respond_with(:redirect) }
    it { lambda { Vote.find(@vote.id) }.should raise_error(ActiveRecord::RecordNotFound) }
  end
end
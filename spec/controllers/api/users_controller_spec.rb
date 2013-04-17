# encoding: utf-8
require 'spec_helper'

describe Api::V1::UsersController do

  let(:user)  { FactoryGirl.create(:user) }
  let(:token) { stub(:accessible? => true, :resource_owner_id => user.id) }
  before      { controller.stubs(:doorkeeper_token).returns(token) }

  describe "show" do
    before do
      get :show, :format => :json
    end

    it { should respond_with(:success) }

    it "should return user JSON representation" do
      JSON.parse(response.body).should == {
        "id" => user.id,
        "first_name" => user.first_name,
        "last_name" => user.last_name,
        "username" => user.username,
        "email" => user.email,
        "organization" => user.organization,
        "city" => user.city,
        "country" => user.country,
        "state" => user.state,
        "reviewer?" => user.reviewer?,
        "organizer?" => user.organizer?,
        "twitter_username" => user.twitter_username,
        "phone" => user.phone,
      }
    end
  end

  describe "make_voter" do
    before do
      post :make_voter, :format => :json
    end

    it { should respond_with(:success) }

    it "should make user a voter" do
      user.reload.should be_voter
    end

    it "should return success JSON" do
      JSON.parse(response.body).should == {"success" => true}
    end
  end

end
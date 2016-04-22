# encoding: UTF-8
require 'spec_helper'

class SampleUser
  include Authorization
  attr_accessor :roles_mask

  def initialize
    roles_mask = 0
  end
end

describe Authorization do
  before(:each) do
    @user = SampleUser.new
  end

  context "persist as bit mask" do
    it "- admin" do
      @user.roles = "admin"
      expect(@user.roles_mask).to eq(1)
      @user.roles = :admin
      expect(@user.roles_mask).to eq(1)
    end

    it "- author" do
      @user.roles = "author"
      expect(@user.roles_mask).to eq(2)
      @user.roles = :author
      expect(@user.roles_mask).to eq(2)
    end

    it "- reviewer" do
      @user.roles = "reviewer"
      expect(@user.roles_mask).to eq(4)
      @user.roles = :reviewer
      expect(@user.roles_mask).to eq(4)
    end

    it "- organizer" do
      @user.roles = "organizer"
      expect(@user.roles_mask).to eq(8)
      @user.roles = :organizer
      expect(@user.roles_mask).to eq(8)
    end

    it "- voter" do
      @user.roles = "voter"
      expect(@user.roles_mask).to eq(16)
      @user.roles = :voter
      expect(@user.roles_mask).to eq(16)
    end

    it "- multiple" do
      @user.roles = ["admin", "reviewer"]
      expect(@user.roles_mask).to eq(5)
      @user.roles = [:admin, :reviewer]
      expect(@user.roles_mask).to eq(5)
    end

    it "- none" do
      @user.roles = []
      expect(@user.roles_mask).to eq(0)
    end

    it "- invalid is ignored" do
      @user.roles = "invalid"
      expect(@user.roles_mask).to eq(0)
      @user.roles = :invalid
      expect(@user.roles_mask).to eq(0)
    end

    it "- mixed valid and invalid (ignores invalid)" do
      @user.roles = ["invalid", "reviewer", "admin"]
      expect(@user.roles_mask).to eq(5)
      @user.roles = [:invalid, :reviewer, :admin]
      expect(@user.roles_mask).to eq(5)
    end
  end

  context "attribute reader for roles" do
    it "- no roles" do
      expect(@user.roles).to be_empty
    end

    it "- single role" do
      @user.roles = "admin"
      expect(@user.roles).to eq(["admin"])

      @user.roles = "reviewer"
      expect(@user.roles).to eq(["reviewer"])

      @user.roles = "author"
      expect(@user.roles).to eq(["author"])

      @user.roles = "organizer"
      expect(@user.roles).to eq(["organizer"])

      @user.roles = "voter"
      expect(@user.roles).to eq(["voter"])
    end

    it "- multiple roles" do
      @user.roles = ["admin", "reviewer", "author"]
      expect(@user.roles).to include("admin")
      expect(@user.roles).to include("author")
      expect(@user.roles).to include("reviewer")
      expect(@user.roles).to_not include("organizer")
    end
  end

  context "defining boolean methods for roles" do
    it "- admin" do
      expect(@user).to_not be_admin
      @user.roles = "admin"
      expect(@user).to be_admin
    end

    it "- author" do
      expect(@user).to_not be_author
      @user.roles = "author"
      expect(@user).to be_author
    end

    it "- reviewer" do
      expect(@user).to_not be_reviewer
      @user.roles = "reviewer"
      expect(@user).to be_reviewer
    end

    it "- organizer" do
      expect(@user).to_not be_organizer
      @user.roles = "organizer"
      expect(@user).to be_organizer
    end

    it "- voter" do
      expect(@user).to_not be_voter
      @user.roles = "voter"
      expect(@user).to be_voter
    end

    it "- multiple" do
      @user.roles = ["admin", "reviewer"]
      expect(@user).to_not be_guest
      expect(@user).to be_admin
      expect(@user).to_not be_author
      expect(@user).to be_reviewer
    end

    it "- none (guest)" do
      @user.roles = []
      expect(@user).to be_guest
      expect(@user).to_not be_admin
      expect(@user).to_not be_author
      expect(@user).to_not be_reviewer
    end
  end

  context "adding a role" do
    it "- string" do
      @user.add_role "admin"
      expect(@user).to be_admin
    end

    it "- symbol" do
      @user.add_role :admin
      expect(@user).to be_admin
    end

    it "- invalid" do
      @user.add_role :invalid
      expect(@user.roles_mask).to eq(0)
    end

    it "- multiple roles" do
      @user.roles = [:admin, :author]
      @user.add_role :reviewer
      expect(@user).to be_admin
      expect(@user).to be_author
      expect(@user).to be_reviewer
    end
  end

  context "removing a role" do
    before(:each) do
      @user.add_role "admin"
    end

    it "- string" do
      @user.remove_role "admin"
      expect(@user).to_not be_admin
    end

    it "- symbol" do
      @user.remove_role :admin
      expect(@user).to_not be_admin
    end

    it "- invalid" do
      @user.remove_role :invalid
      expect(@user.roles_mask).to eq(1)
    end

    it "- multiple roles" do
      @user.add_role :reviewer
      expect(@user).to be_admin
      expect(@user).to be_reviewer

      @user.remove_role "reviewer"
      @user.remove_role :admin
      expect(@user).to_not be_admin
      expect(@user).to_not be_reviewer
    end
  end
end

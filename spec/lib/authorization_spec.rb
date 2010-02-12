require 'spec/spec_helper'

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
      @user.roles_mask.should == 1
      @user.roles = :admin
      @user.roles_mask.should == 1
    end      
    
    it "- author" do
      @user.roles = "author"
      @user.roles_mask.should == 2
      @user.roles = :author
      @user.roles_mask.should == 2
    end

    it "- reviewer" do
      @user.roles = "reviewer"
      @user.roles_mask.should == 4
      @user.roles = :reviewer
      @user.roles_mask.should == 4
    end
    
    it "- multiple" do
      @user.roles = ["admin", "reviewer"]
      @user.roles_mask.should == 5
      @user.roles = [:admin, :reviewer]
      @user.roles_mask.should == 5
    end
    
    it "- none" do
      @user.roles = []
      @user.roles_mask.should == 0
    end
    
    it "- invalid is ignored" do
      @user.roles = "invalid"
      @user.roles_mask.should == 0
      @user.roles = :invalid
      @user.roles_mask.should == 0
    end
    
    it "- mixed valid and invalid (ignores invalid)" do
      @user.roles = ["invalid", "reviewer", "admin"]
      @user.roles_mask.should == 5
      @user.roles = [:invalid, :reviewer, :admin]
      @user.roles_mask.should == 5
    end
  end

  context "attribute reader for roles" do
    it "- no roles" do
      @user.roles.should be_empty
    end

    it "- single role" do
      @user.roles = "admin"
      @user.roles.should == ["admin"]

      @user.roles = "reviewer"
      @user.roles.should == ["reviewer"]

      @user.roles = "author"
      @user.roles.should == ["author"]
    end
    
    it "- multiple roles" do
      @user.roles = ["admin", "reviewer", "author"]
      @user.roles.should include("admin")
      @user.roles.should include("author")
      @user.roles.should include("reviewer")
    end
  end
  
  context "defining boolean methods for roles" do
    it "- admin" do
      @user.should_not be_admin
      @user.roles = "admin"
      @user.should be_admin
    end

    it "- author" do
      @user.should_not be_author
      @user.roles = "author"
      @user.should be_author
    end

    it "- reviewer" do
      @user.should_not be_reviewer
      @user.roles = "reviewer"
      @user.should be_reviewer
    end
    
    it "- multiple" do
      @user.roles = ["admin", "reviewer"]
      @user.should_not be_guest
      @user.should be_admin
      @user.should_not be_author
      @user.should be_reviewer
    end
    
    it "- none (guest)" do
      @user.roles = []
      @user.should be_guest
      @user.should_not be_admin
      @user.should_not be_author
      @user.should_not be_reviewer
    end    
  end
  
  context "adding a role" do
    it "- string" do
      @user.add_role "admin"
      @user.should be_admin
    end
    
    it "- symbol" do
      @user.add_role :admin
      @user.should be_admin
    end
    
    it "- invalid" do
      @user.add_role :invalid
      @user.roles_mask.should == 0
    end
    
    it "- multiple roles" do
      @user.roles = [:admin, :author]
      @user.add_role :reviewer
      @user.should be_admin
      @user.should be_author
      @user.should be_reviewer
    end
  end

  context "removing a role" do
    before(:each) do
      @user.add_role "admin"
    end
    
    it "- string" do
      @user.remove_role "admin"
      @user.should_not be_admin
    end
    
    it "- symbol" do
      @user.remove_role :admin
      @user.should_not be_admin
    end
    
    it "- invalid" do
      @user.remove_role :invalid
      @user.roles_mask.should == 1
    end
    
    it "- multiple roles" do
      @user.add_role :reviewer
      @user.should be_admin
      @user.should be_reviewer
      
      @user.remove_role "reviewer"
      @user.remove_role :admin
      @user.should_not be_admin
      @user.should_not be_reviewer
    end
  end
end

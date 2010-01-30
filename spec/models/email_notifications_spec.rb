require 'spec/spec_helper'

describe EmailNotifications do
  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after do
    ActionMailer::Base.deliveries.clear
  end

  context "user subscription" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should include account details" do
      mail = EmailNotifications.deliver_welcome(@user)
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@user.email]
      mail.content_type.should == "text/html"
  	  mail.body.should =~ /Nome de usuário.*#{@user.username}/
  	  mail.body.should =~ /Senha/
    end
  end

  context "password reset" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should include link with perishable_token" do
      @user.reset_perishable_token!
      mail = EmailNotifications.deliver_password_reset_instructions(@user)
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@user.email]
      mail.content_type.should == "text/html"
  	  mail.body.should =~ /\/password_resets\/#{@user.perishable_token}\/edit/
    end
  end

  context "session submission" do
    it "should be sent to first author"
    it "should be sent to second author, if available"
  end
end

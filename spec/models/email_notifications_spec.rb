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
      mail.content_type.should == "multipart/alternative"
  	  mail.body.should =~ /Nome de usuário.*#{@user.username}/
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
      mail.content_type.should == "multipart/alternative"
  	  mail.body.should =~ /\/password_resets\/#{@user.perishable_token}\/edit/
    end
  end

  context "session submission" do
    before(:each) do
      @session = Factory(:session)
    end
    
    it "should be sent to first author" do
      mail = EmailNotifications.deliver_session_submitted(@session)
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email]
      mail.content_type.should == "multipart/alternative"
  	  mail.body.should =~ /Olá #{@session.author.full_name},/
  	  mail.body.should =~ /#{@session.title}/
  	  mail.body.should =~ /\/sessions\/#{@session.to_param}/
    end
    
    it "should be sent to second author, if available" do
      user = Factory(:user)
      @session.second_author = user
      
      mail = EmailNotifications.deliver_session_submitted(@session)
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@session.author.email, user.email]
      mail.content_type.should == "multipart/alternative"
  	  mail.body.should =~ /Olá #{@session.author.full_name} &amp; #{user.full_name},/
  	  mail.body.should =~ /#{@session.title}/
  	  mail.body.should =~ /\/sessions\/#{@session.to_param}/
    end
  end

  context "reviewer invitation" do
    before(:each) do
      @reviewer = Factory.build(:reviewer, :id => 3)
    end
    
    it "should include link with invitation" do
      mail = EmailNotifications.deliver_reviewer_invitation(@reviewer)
      ActionMailer::Base.deliveries.size.should == 1
      mail.to.should == [@reviewer.user.email]
      mail.content_type.should == "multipart/alternative"
  	  mail.body.should =~ /\/reviewers\/3\/accept/
  	  mail.body.should =~ /\/reviewers\/3\/reject/
    end
  end
end

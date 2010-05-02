require 'spec/spec_helper'

describe ReviewPublisher do
  before(:each) do
    Session.stubs(:count).returns(0)
    Session.stubs(:all).returns([])
    EmailNotifications.stubs(:deliver_notification_of_rejection)
    EmailNotifications.stubs(:deliver_notification_of_acceptance)
    Rails.logger.stubs(:info)
    
    @publisher = ReviewPublisher.new
  end
  
  it "should raise error if there are sessions not reviewed" do
    Session.expects(:count).with(:conditions => ['state = ?', 'created']).returns(2)
    lambda {@publisher.publish}.should raise_error("There are 2 sessions not reviewed")
  end
  
  it "should raise error if reviewed sessions don't have decisions" do
    Session.expects(:count).with(
      :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
      :conditions => ['state = ? AND review_decision_count.cnt = 0', 'in_review']).
      returns(3)
    lambda {@publisher.publish}.should raise_error("There are 3 sessions without decision")
  end
  
  context "Sessions are all reviewed" do
    before(:each) do
      @sessions = [Factory(:session), Factory(:session)]
      Session.stubs(:all).returns(@sessions)
    end
  
    it "should send reject e-mails" do
      Session.expects(:all).with(
        :joins => :review_decision,
        :conditions => ['outcome_id = ? AND published = ?', 2, false]).
        returns(@sessions)
    
      EmailNotifications.expects(:deliver_notification_of_rejection).with(@sessions[0]).with(@sessions[1])
    
      @publisher.publish
    end
  
    it "should send acceptance e-mails" do
      Session.expects(:all).with(
        :joins => :review_decision,
        :conditions => ['outcome_id = ? AND published = ?', 1, false]).
        returns(@sessions)
        
      EmailNotifications.expects(:deliver_notification_of_acceptance).with(@sessions[0]).with(@sessions[1])
    
      @publisher.publish
    end
    
    it "should send reject e-mails before acceptance e-mails" do
      @sessions << Factory(:session)
      
      Session.expects(:all).with(
        :joins => :review_decision,
        :conditions => ['outcome_id = ? AND published = ?', 2, false]).
        returns([@sessions[0], @sessions[2]])
        
      Session.expects(:all).with(
        :joins => :review_decision,
        :conditions => ['outcome_id = ? AND published = ?', 1, false]).
        returns([@sessions[1]])
        
      notifications = sequence('notification')

      EmailNotifications.expects(:deliver_notification_of_rejection).with(@sessions[0]).with(@sessions[2]).in_sequence(notifications)
      EmailNotifications.expects(:deliver_notification_of_acceptance).with(@sessions[1]).in_sequence(notifications)
    
      @publisher.publish
    end
  
    it "should log rejected e-mails sent" do
      Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      Rails.logger.expects(:info).times(2).with("  [REJECT] OK")
      
      @publisher.publish
    end

    it "should log accepted e-mails sent" do
      Rails.logger.expects(:info).with("[SESSION] #{@sessions[0].to_param}")
      Rails.logger.expects(:info).with("[SESSION] #{@sessions[1].to_param}")
      Rails.logger.expects(:info).times(2).with("  [ACCEPT] OK")
      
      @publisher.publish
    end
    
    it "should capture error when notifying acceptance and move on" do
      EmailNotifications.expects(:deliver_notification_of_acceptance).with(@sessions[0]).raises("error")
      EmailNotifications.expects(:deliver_notification_of_acceptance).with(@sessions[1])
      
      Rails.logger.expects(:info).with("  [FAILED ACCEPT] error")
      Rails.logger.expects(:info).with("  [ACCEPT] OK")
      
      @publisher.publish
    end

    it "should capture error when notifying rejection and move on" do
      EmailNotifications.expects(:deliver_notification_of_rejection).with(@sessions[0]).raises("error")
      EmailNotifications.expects(:deliver_notification_of_rejection).with(@sessions[1])
      
      Rails.logger.expects(:info).with("  [FAILED REJECT] error")
      Rails.logger.expects(:info).with("  [REJECT] OK")
      
      @publisher.publish
    end
  end
end
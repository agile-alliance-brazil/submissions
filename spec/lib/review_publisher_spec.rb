# encoding: UTF-8
require 'spec_helper'

describe ReviewPublisher do
  before(:each) do
    Session.stubs(:count).returns(0)
    Session.stubs(:all).returns([])
    EmailNotifications.stubs(:send_notification_of_rejection)
    EmailNotifications.stubs(:send_notification_of_acceptance)
    Rails.logger.stubs(:info)
    Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)
    
    @conference = Conference.current
    
    @publisher = ReviewPublisher.new
  end
  
  it "should raise error if there are sessions not reviewed" do
    Session.expects(:count).with(:conditions => ['state = ? AND conference_id = ?', 'created', @conference.id]).returns(2)
    lambda {@publisher.publish}.should raise_error("There are 2 sessions not reviewed")
  end

  context "validating sessions without decision" do
    it "should raise error if sessions in_review" do
      Session.expects(:count).with(:conditions => ['state = ? AND conference_id = ?', 'in_review', @conference.id]).returns(3)
      lambda {@publisher.publish}.should raise_error("There are 3 sessions without decision")
    end
  
    it "should raise error if reviewed sessions don't have decisions" do
      Session.expects(:count).with(
        :joins => "left outer join (
                  SELECT session_id, count(*) AS cnt
                  FROM review_decisions
                  GROUP BY session_id
                ) AS review_decision_count
                ON review_decision_count.session_id = sessions.id",
        :conditions => ['state IN (?) AND review_decision_count.cnt <> 1 AND conference_id = ?', ['pending_confirmation', 'rejected'], @conference.id]).
        returns(4)
      lambda {@publisher.publish}.should raise_error("There are 4 sessions without decision")
    end
  end
  
  context "Sessions are all reviewed" do
    before(:each) do
      @sessions = [FactoryGirl.create(:session), FactoryGirl.create(:session)]
      FactoryGirl.create(:review_decision, :session => @sessions[0])
      FactoryGirl.create(:review_decision, :session => @sessions[1])
      Session.stubs(:all).returns(@sessions)
    end
  
    it "should send reject e-mails" do
      Session.expects(:all).with(
        :joins => :review_decision,
        :conditions => ['outcome_id = ? AND published = ? AND conference_id = ?', 2, false, @conference.id]).
        returns(@sessions)
    
      EmailNotifications.expects(:send_notification_of_rejection).with(@sessions[0]).with(@sessions[1])
    
      @publisher.publish
    end
  
    it "should send acceptance e-mails" do
      Session.expects(:all).with(
        :joins => :review_decision,
        :conditions => ['outcome_id = ? AND published = ? AND conference_id = ?', 1, false, @conference.id]).
        returns(@sessions)
        
      EmailNotifications.expects(:send_notification_of_acceptance).with(@sessions[0]).with(@sessions[1])
    
      @publisher.publish
    end
    
    it "should mark review decisions as published" do
      @publisher.publish
      @sessions.map(&:review_decision).all? {|r| r.published?}.should be_true
    end
    
    it "should send reject e-mails before acceptance e-mails" do
      notifications = sequence('notification')

      EmailNotifications.expects(:send_notification_of_rejection).
        with(@sessions[0]).
        with(@sessions[1]).
        in_sequence(notifications)
      EmailNotifications.expects(:send_notification_of_acceptance).
        with(@sessions[0]).
        with(@sessions[1]).
        in_sequence(notifications)
    
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
      error = StandardError.new('error')
      EmailNotifications.expects(:send_notification_of_acceptance).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:send_notification_of_acceptance).with(@sessions[1])
      
      Rails.logger.expects(:info).with("  [FAILED ACCEPT] error")
      Rails.logger.expects(:info).with("  [ACCEPT] OK")
      Airbrake.expects(:notify).with(error)
      
      @publisher.publish
    end

    it "should capture error when notifying rejection and move on" do
      error = StandardError.new('error')
      EmailNotifications.expects(:send_notification_of_rejection).with(@sessions[0]).raises(error)
      EmailNotifications.expects(:send_notification_of_rejection).with(@sessions[1])
      
      Rails.logger.expects(:info).with("  [FAILED REJECT] error")
      Rails.logger.expects(:info).with("  [REJECT] OK")
      Airbrake.expects(:notify).with(error)

      @publisher.publish
    end
    
    it "should flush log at the end" do
      Rails.logger.expects(:flush)
      
      @publisher.publish
    end
  end
end

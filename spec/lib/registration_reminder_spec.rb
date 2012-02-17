# encoding: UTF-8
require 'spec_helper'

describe RegistrationReminder do
  before(:each) do
    EmailNotifications.stubs(:registration_reminder).returns(stub(:deliver => true))
    Rails.logger.stubs(:info)
    Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)
    
    @conference = FactoryGirl.create(:conference)
    
    @reminder = RegistrationReminder.new
  end
    
  describe "#publish" do
    before(:each) do
      @attendees = [FactoryGirl.create(:attendee), FactoryGirl.create(:attendee, :cpf => '366.624.533-15')]
      Attendee.stubs(:all).returns(@attendees)
    end
  
    it "should send reminder e-mails" do
      Attendee.expects(:all).with(
        :conditions => ['conference_id = ? AND status = ? AND registration_type_id <> ? AND registration_date < ?', @conference.id, 'pending', 2, Time.zone.local(2011, 5, 21)], :order => 'id').returns(@attendees)    
      EmailNotifications.expects(:registration_reminder).with(@attendees[0]).with(@attendees[1]).returns(stub(:deliver => true))
    
      @reminder.publish
    end

    it "should log reminder e-mails sent" do
      Rails.logger.expects(:info).with("[ATTENDEE] #{@attendees[0].to_param}")
      Rails.logger.expects(:info).with("[ATTENDEE] #{@attendees[1].to_param}")
      Rails.logger.expects(:info).times(2).with("  [REMINDER] OK")
      
      @reminder.publish
    end

    it "should capture error when sending reminder and move on" do
      error = StandardError.new('error')
      EmailNotifications.expects(:registration_reminder).with(@attendees[0]).raises(error)
      EmailNotifications.expects(:registration_reminder).with(@attendees[1]).returns(stub(:deliver => true))
      
      Rails.logger.expects(:info).with("  [FAILED REMINDER] error")
      Rails.logger.expects(:info).with("  [REMINDER] OK")
      Airbrake.expects(:notify).with(error)
      
      @reminder.publish
    end

    it "should flush log at the end" do
      Rails.logger.expects(:flush)
      
      @reminder.publish
    end
  end
end

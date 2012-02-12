# encoding: UTF-8
require 'spec_helper'

describe PaymentNotificationsController do
  describe "POST create" do
    it "should create PaymentNotification" do
      attendee = FactoryGirl.create(:attendee)
      
      lambda {
        post :create, :txn_id => "ABCABC", :invoice => attendee.id, :custom => 'Attendee', :payment_status => "Completed"
      }.should change(PaymentNotification, :count).by(1)      
    end
  end
end

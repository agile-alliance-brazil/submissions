require 'spec_helper'

describe PaypalHelper do
  describe "paypal_url" do
    it "should build URL from attendee" do
      attendee = Factory(:attendee, :registration_date => Time.zone.local(2011, 5, 15))
      
    end
  end
end

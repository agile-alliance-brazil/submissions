require 'spec_helper'

describe RegistrationType do  
  context "associations" do
    should_belong_to :conference
    should_have_many :registration_prices
  end
  
  describe "price" do
    it "delegates to RegistrationPeriod" do
      type = RegistrationType.find_by_title('registration_type.student')
      late = RegistrationPeriod.find_by_title('registration_period.late')
      type.price(late.start_at + 1.day).should == 110.00
    end
  end
end

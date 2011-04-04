require 'spec_helper'

describe RegistrationPeriod do  
  context "inclusion" do
    before :each do
      @period = Factory(:registration_period)
    end
    
    it "should not include date before its start" do
      @period.include?(@period.start_at - 1.second).should be_false
    end

    it "should include its start date" do
      @period.include?(@period.start_at).should be_true
    end
    
    it "should include a date between start and end" do
      @period.include?(@period.start_at + 5).should be_true
    end
    
    it "should include end date" do
      @period.include?(@period.end_at).should be_true
    end
    
    it "should not include date after end date" do
      @period.include?(@period.end_at + 1.second).should be_false
    end
  end
end

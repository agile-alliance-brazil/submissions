# encoding: UTF-8
require 'spec_helper'

describe RegistrationPeriod do  
  context "prices" do
    before do
      @pre_register = RegistrationPeriod.find_by_title('registration_period.pre_register')
      @early_bird = RegistrationPeriod.find_by_title('registration_period.early_bird')
      @regular = RegistrationPeriod.find_by_title('registration_period.regular')
      @late = RegistrationPeriod.find_by_title('registration_period.late')      
    end
    
    context "for registration types" do
      before do
        @individual = RegistrationType.find_by_title('registration_type.individual')
        @group = RegistrationType.find_by_title('registration_type.group')
        @student = RegistrationType.find_by_title('registration_type.student')
      end
    
      it "pre_register" do
        @pre_register.price_for_registration_type(@individual).should == 130.00
        @pre_register.price_for_registration_type(@group).should == 110.00
        @pre_register.price_for_registration_type(@student).should == 50.00
        lambda { @pre_register.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "early_bird" do
        @early_bird.price_for_registration_type(@individual).should == 165.00
        @early_bird.price_for_registration_type(@group).should == 135.00
        @early_bird.price_for_registration_type(@student).should == 65.00
        lambda { @early_bird.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "regular" do
        @regular.price_for_registration_type(@individual).should == 220.00
        @regular.price_for_registration_type(@group).should == 165.00
        @regular.price_for_registration_type(@student).should == 90.00
        lambda { @regular.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "late" do
        @late.price_for_registration_type(@individual).should == 275.00
        @late.price_for_registration_type(@group).should == 190.00
        @late.price_for_registration_type(@student).should == 110.00
        lambda { @late.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end
    end

    context "for registration types" do
      before do
        @csm = Course.find_by_name('course.csm.name')
        @cspo = Course.find_by_name('course.cspo.name')
        @lean = Course.find_by_name('course.lean.name')
        @tdd = Course.find_by_name('course.tdd.name')
      end
    
      it "pre_register" do
        lambda { @pre_register.price_for_course(@csm) }.should raise_error(InvalidPrice)
        lambda { @pre_register.price_for_course(@cspo) }.should raise_error(InvalidPrice)
        lambda { @pre_register.price_for_course(@lean) }.should raise_error(InvalidPrice)
        lambda { @pre_register.price_for_course(@tdd) }.should raise_error(InvalidPrice)
      end

      it "early_bird" do
        @early_bird.price_for_course(@csm).should == 990.00
        @early_bird.price_for_course(@cspo).should == 990.00
        @early_bird.price_for_course(@lean).should == 280.00
        @early_bird.price_for_course(@tdd).should == 280.00
      end

      it "regular" do
        @regular.price_for_course(@csm).should == 1290.00
        @regular.price_for_course(@cspo).should == 1290.00
        @regular.price_for_course(@lean).should == 340.00
        @regular.price_for_course(@tdd).should == 340.00
      end

      it "late" do
        @late.price_for_course(@csm).should == 1650.00
        @late.price_for_course(@cspo).should == 1650.00
        @late.price_for_course(@lean).should == 390.00
        @late.price_for_course(@tdd).should == 390.00
      end
    end
  end
  
  context "appropriate period" do
    before :each do
      @period = RegistrationPeriod.find_by_title('registration_period.regular')
    end
    
    it "should not include date before its start" do
      RegistrationPeriod.for(@period.start_at - 1.second).first.should == RegistrationPeriod.find_by_title('registration_period.early_bird')
    end

    it "should include its start date" do
      RegistrationPeriod.for(@period.start_at).first.should == @period
    end
    
    it "should include a date between start and end" do
      RegistrationPeriod.for(@period.start_at + 5).first.should == @period
    end
    
    it "should include end date" do
      RegistrationPeriod.for(@period.end_at).first.should == @period
    end
    
    it "should not include date after end date" do
      RegistrationPeriod.for(@period.end_at + 1.week).first.should == RegistrationPeriod.find_by_title('registration_period.late')
    end
    
    it "should not have any period before early_bird" do
      early = RegistrationPeriod.find_by_title('registration_period.early_bird')
      RegistrationPeriod.for(early.start_at - 1.second).first.should be_nil
    end
    
    it "should not have any period after late" do
      early = RegistrationPeriod.find_by_title('registration_period.late')
      RegistrationPeriod.for(early.end_at + 1.second).first.should be_nil
    end
  end
end

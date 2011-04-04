require 'spec_helper'

describe RegistrationType do
  it "should provide translated options for select" do
    RegistrationType.options_for_select.should include(["Individual", 'individual'])
    RegistrationType.options_for_select.should include(["Estudante", 'student'])
    RegistrationType.options_for_select.size.should == 2
  end
  
  it "should provide valid values" do
    RegistrationType.valid_values.should == %w(individual student)
  end
  
  it "should provide factory method" do
    RegistrationType.for("individual").should be_an_instance_of(RegistrationType::Individual)
    RegistrationType.for("student").should be_an_instance_of(RegistrationType::Student)
    lambda {RegistrationType.for("invalid")}.should raise_error("Invalid registration type: invalid")
  end
  
  describe RegistrationType::Individual do
    context "fees" do
      it "on pre registration period" do
        Time.zone.stubs(:now).returns(RegistrationPeriod::PRE_REGISTERED_START + 1.day)
        RegistrationType::Individual.new.total.should == 165.00
      end
    end
  end
  
end

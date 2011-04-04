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
end

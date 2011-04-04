require 'spec_helper'

describe RegistrationType do
  it "should provide translated options for select" do
    RegistrationType.options_for_select.should include(['individual', "Individual"])
    RegistrationType.options_for_select.should include(['student', "Estudante"])
    RegistrationType.options_for_select.size.should == 2
  end
  
  it "should provide valid values" do
    RegistrationType.valid_values.should == %w(individual student)
  end
end

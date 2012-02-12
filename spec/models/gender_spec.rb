# encoding: UTF-8
require 'spec_helper'

describe Gender do
  it "should provide translated options for select" do
    Gender.options_for_select.should include(['Masculino', 'M'])
    Gender.options_for_select.should include(['Feminino', 'F'])
    Gender.options_for_select.size.should == 2
  end
  
  it "should provide valid values" do
    Gender.valid_values.should == %w(M F)
  end
  
  it "should provide title for given value" do
    Gender.title_for('M').should == 'Masculino'
    Gender.title_for('F').should == 'Feminino'
  end
end

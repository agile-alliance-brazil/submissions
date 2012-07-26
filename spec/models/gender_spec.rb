# encoding: UTF-8
require 'spec_helper'

describe Gender do
  it "should provide translated options for select" do
    Gender.options_for_select.should include([I18n.t('gender.male'), 'M'])
    Gender.options_for_select.should include([I18n.t('gender.female'), 'F'])
    Gender.options_for_select.size.should == 2
  end

  it "should provide valid values" do
    Gender.valid_values.should == %w(M F)
  end

  it "should provide title for given value" do
    Gender.title_for('M').should == I18n.t('gender.male')
    Gender.title_for('F').should == I18n.t('gender.female')
  end
end

# encoding: UTF-8
require 'spec_helper'

describe 'Factories' do
  FactoryGirl.factories.each do |factory|
    describe ":#{factory.name}" do
      subject { FactoryGirl.build(factory.name) }
      it { should be_valid }
    end
  end
end
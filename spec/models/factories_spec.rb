# frozen_string_literal: true

require 'spec_helper'

describe 'Factories' do
  FactoryBot.factories.each do |factory|
    describe ":#{factory.name}" do
      subject { FactoryBot.build(factory.name) }
      it { should be_valid }
    end
  end
end

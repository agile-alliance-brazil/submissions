# encoding: UTF-8
require 'spec_helper'

describe AllHands do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :title }

    it { should_not allow_mass_assignment_of :id}
  end
end

# encoding: UTF-8
require 'spec_helper'

describe Room do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :name }
    it { should allow_mass_assignment_of :capacity }
    it { should allow_mass_assignment_of :conference_id }

    it { should_not allow_mass_assignment_of :id }
  end

  context "associations" do
    it { should belong_to :conference }
    it { should have_many :activities }
  end
end

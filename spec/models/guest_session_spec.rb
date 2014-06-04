# encoding: UTF-8
require 'spec_helper'

describe GuestSession, type: :model do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :title }
    it { should allow_mass_assignment_of :author }
    it { should allow_mass_assignment_of :summary }
    it { should allow_mass_assignment_of :conference_id }
    it { should allow_mass_assignment_of :keynote }

    it { should_not allow_mass_assignment_of :id }
  end

  context "associations" do
    it { should belong_to :conference }
  end
end

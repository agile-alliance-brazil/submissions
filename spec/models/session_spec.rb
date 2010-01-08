require File.dirname(__FILE__) + '/../spec_helper'

describe Session do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :title
    should_allow_mass_assignment_of :summary
    should_allow_mass_assignment_of :description
    should_allow_mass_assignment_of :mechanics
    should_allow_mass_assignment_of :benefits
    should_allow_mass_assignment_of :target_audience
    should_allow_mass_assignment_of :audience_limit
    should_allow_mass_assignment_of :author_id
    should_allow_mass_assignment_of :experience
  
    should_not_allow_mass_assignment_of :evil_attr
  end
  
  context "associations" do
    should_belong_to :author, :class_name => 'User'
  end
  
  context "validations" do
    should_validate_presence_of :title
    should_validate_presence_of :summary
    should_validate_presence_of :description
    should_validate_presence_of :benefits
    should_validate_presence_of :target_audience
    should_validate_presence_of :author_id
    should_validate_presence_of :experience
  end
  
end

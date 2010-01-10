require 'spec/spec_helper'

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
    should_allow_mass_assignment_of :track_id
    should_allow_mass_assignment_of :session_type_id
    should_allow_mass_assignment_of :experience
  
    should_not_allow_mass_assignment_of :evil_attr
  end
  
  context "associations" do
    should_belong_to :author, :class_name => 'User'
    should_belong_to :track
    should_belong_to :session_type
  end
  
  context "validations" do
    should_validate_presence_of :title
    should_validate_presence_of :summary
    should_validate_presence_of :description
    should_validate_presence_of :benefits
    should_validate_presence_of :target_audience
    should_validate_presence_of :author_id
    should_validate_presence_of :track_id
    should_validate_presence_of :session_type_id
    should_validate_presence_of :experience
    should_validate_presence_of :mechanics, :if => :workshop?
  end
  
  it "should determine if it's workshop" do
    workshop = SessionType.find_by_title('session_types.workshop.title')
    session = Factory(:session)
    session.should_not be_workshop
    session.session_type = workshop
    session.should be_workshop
  end
  
end

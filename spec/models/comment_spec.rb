require 'spec_helper'

describe Comment do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :comment
    should_allow_mass_assignment_of :user_id
    should_allow_mass_assignment_of :commentable_id
  
    should_not_allow_mass_assignment_of :id
  end
  
  it_should_trim_attributes Comment, :comment
  
  context "associations" do
    should_belong_to :user
    should_belong_to :commentable, :polymorphic => true
  end
  
  context "validations" do
    should_validate_presence_of :comment
    should_validate_presence_of :user_id
    should_validate_presence_of :commentable_id
    
    should_validate_length_of :comment, :maximum => 1000
  end
end

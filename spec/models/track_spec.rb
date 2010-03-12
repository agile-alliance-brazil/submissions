require 'spec/spec_helper'

describe Track do
  
  context "validations" do
    should_validate_presence_of :title
    should_validate_presence_of :description
  end
  
  context "associations" do
    should_have_many :sessions
    should_have_many :track_ownerships, :class_name => 'Organizer'
    should_have_many :organizers, :through => :track_ownerships, :source => :user
  end

end

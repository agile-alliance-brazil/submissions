require 'spec/spec_helper'

describe User do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :first_name
    should_allow_mass_assignment_of :last_name
    should_allow_mass_assignment_of :username
    should_allow_mass_assignment_of :email
    should_allow_mass_assignment_of :password
    should_allow_mass_assignment_of :password_confirmation
    should_allow_mass_assignment_of :phone
    should_allow_mass_assignment_of :state
    should_allow_mass_assignment_of :city
    should_allow_mass_assignment_of :organization
    should_allow_mass_assignment_of :website_url
    should_allow_mass_assignment_of :bio
  
    should_not_allow_mass_assignment_of :evil_attr
  end

  context "validations" do
    should_validate_presence_of :first_name
    should_validate_presence_of :last_name
    should_validate_presence_of :phone
    should_validate_presence_of :state
    should_validate_presence_of :city
    should_validate_presence_of :bio
    
    should_validate_length_of :username, :minimum => 3
    should_validate_length_of :password, :minimum => 4
    should_validate_length_of :password_confirmation, :minimum => 4
    should_validate_length_of :email, :minimum => 6
    
    should_allow_values_for :username, "dtsato", "123", "a b c", "danilo.sato", "dt-sato@dt_sato.com"
    should_not_allow_values_for :username, "dt$at0", "<>/?", ")(*&^%$@!", "[=+]"
    
    should_allow_values_for :email, "user@domain.com.br", "test_user.name@a.co.uk"
    should_not_allow_values_for :email, "a", "a@", "a@a", "@12.com"
    
    should_validate_confirmation_of :password
  end
  
  context "associations" do
    should_have_many :sessions, :foreign_key => 'author_id'
  end
  
  context "named scopes" do
    should_have_scope :search, :conditions => ['username LIKE ?', "danilo%"], :with => 'danilo'
  end
  
  it "should provide full name" do
    user = User.new(:first_name => "Danilo", :last_name => "Sato")
    user.full_name.should == "Danilo Sato"
  end
end

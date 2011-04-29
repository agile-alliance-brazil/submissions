require 'spec_helper'

describe RegistrationGroup do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :name
    should_allow_mass_assignment_of :cnpj
    should_allow_mass_assignment_of :state_inscription
    should_allow_mass_assignment_of :municipal_inscription
    should_allow_mass_assignment_of :contact_name
    should_allow_mass_assignment_of :contact_email
    should_allow_mass_assignment_of :contact_email_confirmation
    should_allow_mass_assignment_of :phone
    should_allow_mass_assignment_of :country
    should_allow_mass_assignment_of :state
    should_allow_mass_assignment_of :city
    should_allow_mass_assignment_of :fax
    should_allow_mass_assignment_of :address
    should_allow_mass_assignment_of :neighbourhood
    should_allow_mass_assignment_of :zipcode
    should_allow_mass_assignment_of :total_attendees

    should_not_allow_mass_assignment_of :id
  end
  
  it_should_trim_attributes RegistrationGroup, :name, :state_inscription, :municipal_inscription, :contact_email, 
                                               :contact_name, :phone, :fax, :country, :state, :city, :address,
                                               :neighbourhood, :zipcode
  
  context "associations" do
    should_have_many :attendees
  end
  
  context "validations" do
    context "brazilians" do
      subject { Factory.build(:registration_group) }
      should_validate_presence_of :name
      should_validate_presence_of :contact_email
      should_validate_presence_of :contact_name
      should_validate_presence_of :phone
      should_validate_presence_of :fax
      should_validate_presence_of :country
      should_validate_presence_of :state
      should_validate_presence_of :city
      should_validate_presence_of :address
      should_validate_presence_of :zipcode
      should_validate_presence_of :cnpj
      should_validate_presence_of :state_inscription
      should_validate_presence_of :municipal_inscription
      should_validate_presence_of :total_attendees
    end
    
    context "non brazilians" do
      subject {Factory(:registration_group, :country => 'US')}
      should_not_validate_presence_of :cnpj
      should_not_validate_presence_of :state_inscription
      should_not_validate_presence_of :municipal_inscription
      should_not_validate_presence_of :state
    end
    
    should_validate_confirmation_of :contact_email
    
    should_validate_length_of :name, :maximum => 100, :allow_blank => true
    should_validate_length_of :country, :maximum => 100, :allow_blank => true
    should_validate_length_of :state, :maximum => 100, :allow_blank => true
    should_validate_length_of :city, :maximum => 100, :allow_blank => true
    should_validate_length_of :address, :maximum => 300, :allow_blank => true
    should_validate_length_of :neighbourhood, :maximum => 100, :allow_blank => true
    should_validate_length_of :contact_name, :maximum => 100, :allow_blank => true
    should_validate_length_of :zipcode, :maximum => 10, :allow_blank => true
    should_validate_length_of :contact_email, :within => 6..100, :allow_blank => true
    
    should_allow_values_for :contact_email, "user@domain.com.br", "test_user.name@a.co.uk"
    should_not_allow_values_for :contact_email, "a", "a@", "a@a", "@12.com"
    
    should_allow_values_for :phone, "1234-2345", "+55 11 5555 2234", "+1 (304) 543.3333", "07753423456"
    should_not_allow_values_for :phone, "a", "1234-bfd", ")(*&^%$@!", "[=+]"

    should_allow_values_for :fax, "1234-2345", "+55 11 5555 2234", "+1 (304) 543.3333", "07753423456"
    should_not_allow_values_for :fax, "a", "1234-bfd", ")(*&^%$@!", "[=+]"

    should_allow_values_for :cnpj, "69.103.604/0001-60", "69103604000160"
    should_not_allow_values_for :cnpj, "12345", "66.666.666/6666-66", "66666666666666"
    
    should_validate_numericality_of :total_attendees, :only_integer => true, :greater_than_or_equal_to => 5, :allow_blank => true
    
    context "uniqueness" do
      before { Factory(:registration_group) }
      should_validate_uniqueness_of :cnpj, :allow_blank => true
    end
  end
  
  describe "complete?" do
    before do
      @registration_group = Factory.build(:registration_group, :total_attendees => 5)
    end
    
    it "should not be complete while number of attendees is less than total" do
      5.times do
        @registration_group.should_not be_complete
        @registration_group.attendees.build(Factory.attributes_for(:attendee))
      end
    end
    
    it "should be complete once number of attendees reaches total" do
      5.times { @registration_group.attendees.build(Factory.attributes_for(:attendee)) }
      @registration_group.should be_complete
    end
  end
  
  describe "registration fee" do
    before do
      @date = Time.zone.local(2011, 05, 01, 12, 0, 0)
    end
    
    it "should sum registration fees for all attendees" do
      @registration_group = Factory(:registration_group)
      Factory(:attendee, :registration_date => @date, :registration_group => @registration_group, :registration_type => RegistrationType.find_by_title('registration_type.group'))
      Factory(:attendee, :registration_date => @date, :registration_group => @registration_group, :registration_type => RegistrationType.find_by_title('registration_type.group'), :cpf => "366.624.533-15")
      
      @registration_group.registration_fee.should == 135.00 * 2
    end
  end
  
  describe "to_param" do
    it "should append group name" do
      Factory(:registration_group, :name => "Some random name").to_param.ends_with?("-some-random-name").should be_true
    end
  end
end

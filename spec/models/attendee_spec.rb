# encoding: utf-8
require 'spec_helper'

describe Attendee do
  context "protect from mass assignment" do
    should_allow_mass_assignment_of :first_name
    should_allow_mass_assignment_of :last_name
    should_allow_mass_assignment_of :email
    should_allow_mass_assignment_of :email_confirmation
    should_allow_mass_assignment_of :organization
    should_allow_mass_assignment_of :phone
    should_allow_mass_assignment_of :country
    should_allow_mass_assignment_of :state
    should_allow_mass_assignment_of :city
    should_allow_mass_assignment_of :badge_name
    should_allow_mass_assignment_of :cpf
    should_allow_mass_assignment_of :gender
    should_allow_mass_assignment_of :twitter_user
    should_allow_mass_assignment_of :address
    should_allow_mass_assignment_of :neighbourhood
    should_allow_mass_assignment_of :zipcode
    should_allow_mass_assignment_of :registration_type_value
    should_allow_mass_assignment_of :status_event
    should_allow_mass_assignment_of :conference_id

    should_not_allow_mass_assignment_of :id
  end
  
  it_should_trim_attributes Attendee, :first_name, :last_name, :email, :organization, :phone,
                                      :country, :state, :city, :badge_name, :twitter_user,
                                      :address, :neighbourhood, :zipcode
                                      
  context "twitter user" do
    it "should remove @ from start if present" do
      attendee = Attendee.new(:twitter_user => '@agilebrazil')
      attendee.twitter_user.should == 'agilebrazil'
    end
    
    it "should keep as given if doesnt start with @" do
      attendee = Attendee.new(:twitter_user => 'agilebrazil')
      attendee.twitter_user.should == 'agilebrazil'
    end
  end
  
  context "associations" do
    should_belong_to :conference
    
    # should_have_many :courses, :dependent => :destroy
  end
  
  context "validations" do
    should_validate_presence_of :first_name
    should_validate_presence_of :last_name
    should_validate_presence_of :email
    should_validate_presence_of :phone
    should_validate_presence_of :country
    # should_validate_presence_of :state
    should_validate_presence_of :city
    should_validate_presence_of :address
    should_validate_presence_of :gender
    should_validate_presence_of :zipcode
    should_validate_presence_of :registration_type_value
    should_validate_presence_of :conference_id
    # should_validate_presence_of :cpf
    should_not_validate_presence_of :organization
    
    context "student" do
      subject {Factory(:attendee, :registration_type_value => 'student')}
      should_validate_presence_of :organization
    end
    
    context "non brazilians" do
      subject {Factory(:attendee, :country => 'US')}
      should_not_validate_presence_of :cpf
      should_not_validate_presence_of :state
    end
    
    should_validate_existence_of :conference
    
    should_validate_confirmation_of :email
    
    should_validate_length_of :first_name, :maximum => 100, :allow_blank => true
    should_validate_length_of :last_name, :maximum => 100, :allow_blank => true
    should_validate_length_of :badge_name, :maximum => 200, :allow_blank => true
    should_validate_length_of :organization, :maximum => 100, :allow_blank => true
    should_validate_length_of :country, :maximum => 100, :allow_blank => true
    should_validate_length_of :state, :maximum => 100, :allow_blank => true
    should_validate_length_of :city, :maximum => 100, :allow_blank => true
    should_validate_length_of :address, :maximum => 300, :allow_blank => true
    should_validate_length_of :neighbourhood, :maximum => 100, :allow_blank => true
    should_validate_length_of :zipcode, :maximum => 10, :allow_blank => true
    should_validate_length_of :twitter_user, :maximum => 100, :allow_blank => true
    should_validate_length_of :email, :within => 6..100
    
    should_allow_values_for :email, "user@domain.com.br", "test_user.name@a.co.uk"
    should_not_allow_values_for :email, "a", "a@", "a@a", "@12.com"
    
    should_allow_values_for :phone, "1234-2345", "+55 11 5555 2234", "+1 (304) 543.3333", "07753423456"
    should_not_allow_values_for :phone, "a", "1234-bfd", ")(*&^%$@!", "[=+]"

    should_allow_values_for :cpf, "111.444.777-35", "11144477735"
    should_not_allow_values_for :cpf, "12345", "111.111.111-11", "11111111111"
    
    should_validate_inclusion_of :gender, :in => Gender.valid_values, :allow_blank => true
    should_validate_inclusion_of :registration_type_value, :in => RegistrationType.valid_values, :allow_blank => true
    
    context "uniqueness" do
      before { Factory(:attendee) }
      should_validate_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
      should_validate_uniqueness_of :cpf, :allow_blank => true
    end
  end
  
  context "state machine" do
    before(:each) do
      @attendee = Factory.build(:attendee)
    end
    
    context "State: pending" do
      it "should be the initial state" do
        @attendee.should be_pending
      end
      
      it "should allow confirming" do
        @attendee.confirm.should be_true
        @attendee.should_not be_pending
        @attendee.should_not be_expired
      end

      it "should allow expiring" do
        @attendee.expire.should be_true
        @attendee.should_not be_pending
        @attendee.should_not be_confirmed
      end
    end
    
    context "State: confirmed" do
      before(:each) do
        @attendee.confirm
        @attendee.should be_confirmed
      end
      
      it "should not allow confirming again" do
        @attendee.confirm.should be_false
        @attendee.should be_confirmed
      end
      
      it "should not allow expiring" do
        @attendee.expire.should be_false
        @attendee.should_not be_expired
        @attendee.should be_confirmed
      end
    end

    context "State: expired" do
      before(:each) do
        @attendee.expire
        @attendee.should be_expired
      end
      
      it "should not allow expiring again" do
        @attendee.expire.should be_false
        @attendee.should be_expired
      end
      
      it "should not allow confirming" do
        @attendee.confirm.should be_false
        @attendee.should be_expired
      end      
    end
  end
  
  it "should provide full name" do
    attendee = Factory.build(:attendee, :first_name => "Danilo", :last_name => "Sato")
    attendee.full_name.should == "Danilo Sato"
  end
  
  it "should be student when RegistrationType is student" do
    attendee = Factory.build(:attendee, :registration_type_value => 'student')
    attendee.should be_student
  end
  
  it "should not be student when RegistrationType is individual" do
    attendee = Factory.build(:attendee, :registration_type_value => 'individual')
    attendee.should_not be_student
  end
    
  it "should be male for gender male" do
    attendee = Factory.build(:attendee, :gender => 'M')
    attendee.should be_male
  end
  
  it "should not be male for gender female" do
    attendee = Factory.build(:attendee, :gender => 'F')
    attendee.should_not be_male
  end
  
  it "should create value object for registration type" do
    attendee = Factory.build(:attendee, :registration_type_value => 'student')
    attendee.registration_type.should be_an_instance_of(RegistrationType::Student)

    attendee = Factory.build(:attendee, :registration_type_value => 'individual')
    attendee.registration_type.should be_an_instance_of(RegistrationType::Individual)
  end
  
  it "should delegate registration fee to registration type" do
    RegistrationType::Individual.any_instance.expects(:total).returns(165.00)
    attendee = Factory.build(:attendee, :registration_type_value => 'individual')
    attendee.registration_fee.should == 165.00
  end
end
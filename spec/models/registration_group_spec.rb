# encoding: UTF-8
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
    should_allow_mass_assignment_of :payment_agreement
    should_allow_mass_assignment_of :status_event

    should_not_allow_mass_assignment_of :id
  end

  it_should_trim_attributes RegistrationGroup, :name, :state_inscription, :municipal_inscription, :contact_email,
                                               :contact_name, :phone, :fax, :country, :state, :city, :address,
                                               :neighbourhood, :zipcode

  context "associations" do
    should_have_many :attendees
    should_have_many :payment_notifications, :as => :invoicer
    should_have_many :course_attendances, :through => :attendees
  end

  context "validations" do
    context "brazilians" do
      subject { FactoryGirl.build(:registration_group) }
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
      subject {FactoryGirl.build(:registration_group, :country => 'US')}
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

    it "should validate that payment agreement is checked on confirmation" do
      registration_group = FactoryGirl.build(:registration_group, :payment_agreement => false)
      registration_group.expects(:attendees).returns([1, 2, 3, 4, 5])
      registration_group.complete.should be_true
      registration_group.confirm.should be_false
      registration_group.errors[:payment_agreement].should include("deve ser aceito")
    end

    it "should validate that number of attendees reaches total on completion" do
      registration_group = FactoryGirl.build(:registration_group, :total_attendees => 5)
      registration_group.complete.should be_false
      registration_group.errors[:total_attendees].should include("não possui 5 participantes cadastrados")

      registration_group.expects(:attendees).returns([1, 2, 3, 4, 5])
      registration_group.complete.should be_true
    end
  end

  describe "callbacks" do
    it "should set URI token after initialized" do
      RegistrationGroup.expects(:generate_token).with(:uri_token).returns('abc123')
      registration_group = FactoryGirl.build(:registration_group)
      registration_group.uri_token.should == 'abc123'
    end
  end

  context "state machine" do
    before(:each) do
      @registration_group = FactoryGirl.build(:registration_group)
    end

    context "State: incomplete" do
      it "should be the initial state" do
        @registration_group.should be_incomplete
      end

      it "should not allow paying" do
        @registration_group.pay.should be_false
        @registration_group.should be_incomplete
      end

      it "should not allow confirming" do
        @registration_group.confirm.should be_false
        @registration_group.should be_incomplete
      end

      it "should allow completing" do
        @registration_group.expects(:attendees).returns([1, 2, 3, 4, 5])
        @registration_group.complete.should be_true
        @registration_group.should be_complete
      end
    end

    context "State: complete" do
      before(:each) do
        @attendees = []
        5.times { @attendees << FactoryGirl.build(:attendee) }
        @registration_group.stubs(:attendees).returns(@attendees)
        @registration_group.complete
        @registration_group.should be_complete
      end

      it "should allow confirming" do
        @registration_group.confirm.should be_true
        @registration_group.should_not be_complete
        @registration_group.should be_confirmed
      end

      it "should not allow completing again" do
        @registration_group.complete.should be_false
        @registration_group.should be_complete
      end

      it "should allow pay" do
        @registration_group.pay.should be_true
        @registration_group.should be_paid
      end

      it "should pay all attendees" do
        @attendees.each {|a| a.expects(:pay).returns(true) }
        @registration_group.pay.should be_true
      end

      it "should confirm all attendees" do
        @attendees.each {|a| a.expects(:confirm).returns(true) }
        @registration_group.confirm.should be_true
      end

    end

    context "State: paid" do
      before(:each) do
        @attendees = []
        5.times { @attendees << FactoryGirl.build(:attendee) }
        @registration_group.stubs(:attendees).returns(@attendees)
        @registration_group.complete
        @registration_group.pay
        @registration_group.should be_paid
      end

      it "should allow confirming" do
        @registration_group.confirm.should be_true
        @registration_group.should_not be_paid
        @registration_group.should be_confirmed
      end

      it "should not allow paying again" do
        @registration_group.pay.should be_false
        @registration_group.should be_paid
      end

      it "should not allow completing" do
        @registration_group.complete.should be_false
        @registration_group.should be_paid
      end

      it "should confirm all attendees" do
        @attendees.each {|a| a.expects(:confirm).returns(true) }
        @registration_group.confirm.should be_true
      end

    end

    context "State: confirmed" do
      before(:each) do
        @attendees = []
        5.times { @attendees << FactoryGirl.build(:attendee) }
        @registration_group.stubs(:attendees).returns(@attendees)
        @registration_group.complete
        @registration_group.confirm
        @registration_group.should be_confirmed
      end

      it "should not allow confirming again" do
        @registration_group.confirm.should be_false
        @registration_group.should be_confirmed
      end

      it "should not allow paying" do
        @registration_group.pay.should be_false
        @registration_group.should be_confirmed
      end

      it "should not allow completing" do
        @registration_group.complete.should be_false
        @registration_group.should be_confirmed
      end
    end

    context "Transition to confirmed" do
      before do
        @attendees = []
        5.times { @attendees << FactoryGirl.build(:attendee, :registration_date => Time.zone.local(2011, 4, 25)) }
        @registration_group.stubs(:attendees).returns(@attendees)
        @registration_group.complete
      end

      it "should send confirmation e-mail to registration group owner" do
        email = stub(:deliver => true)
        EmailNotifications.expects(:registration_group_confirmed).with(@registration_group).returns(email)
        @registration_group.confirm
      end

      it "should notify Hoptoad on error" do
        error = StandardError.new('error')
        EmailNotifications.expects(:registration_group_confirmed).with(@registration_group).raises(error)
        HoptoadNotifier.expects(:notify).with(error)
        @registration_group.confirm
      end
    end
  end

  describe "registration fee" do
    before do
      @date = Time.zone.local(2011, 05, 01, 12, 0, 0)
    end

    it "should sum registration fees for all attendees" do
      @registration_group = FactoryGirl.create(:registration_group)
      FactoryGirl.create(:attendee, :registration_date => @date, :registration_group => @registration_group, :registration_type => RegistrationType.find_by_title('registration_type.group'))
      FactoryGirl.create(:attendee, :registration_date => @date, :registration_group => @registration_group, :registration_type => RegistrationType.find_by_title('registration_type.group'), :cpf => "366.624.533-15")

      @registration_group.registration_fee.should == 135.00 * 2
    end
  end

  describe "to_param" do
    it "should append group name" do
      FactoryGirl.build(:registration_group, :name => "Some random name").to_param.ends_with?("-some-random-name").should be_true
    end
  end

  describe "registration period" do
    before(:each) do
      @group = FactoryGirl.create(:registration_group)
    end

    context "no attendees" do
      it "should be nil" do
        @group.registration_period.should be_nil
      end
    end

    context "attendee is pre-registered" do
      before(:each) do
        attendee = FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 4, 5), :registration_group => @group, :registration_type => RegistrationType.find_by_title('registration_type.group'))
        @pre = PreRegistration.new(:email => attendee.email, :used => false)
        @pre.save!
      end

      after(:each) do
        @pre.destroy
      end

      it "should return pre-registration period for registration" do
        @group.registration_period.should == RegistrationPeriod.find_by_title('registration_period.pre_register')
      end
    end

    context "attendee not pre-registered" do
      before(:each) do
        FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 4, 5), :registration_group => @group, :registration_type => RegistrationType.find_by_title('registration_type.group'))
      end

      it "should return normal period for registration" do
        @group.registration_period.should == RegistrationPeriod.find_by_title('registration_period.early_bird')
      end
    end
  end

  # describe "course_attendances"
end

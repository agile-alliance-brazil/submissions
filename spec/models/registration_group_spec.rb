# encoding: UTF-8
require 'spec_helper'

describe RegistrationGroup do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :name }
    it { should allow_mass_assignment_of :cnpj }
    it { should allow_mass_assignment_of :state_inscription }
    it { should allow_mass_assignment_of :municipal_inscription }
    it { should allow_mass_assignment_of :contact_name }
    it { should allow_mass_assignment_of :contact_email }
    it { should allow_mass_assignment_of :contact_email_confirmation }
    it { should allow_mass_assignment_of :phone }
    it { should allow_mass_assignment_of :country }
    it { should allow_mass_assignment_of :state }
    it { should allow_mass_assignment_of :city }
    it { should allow_mass_assignment_of :fax }
    it { should allow_mass_assignment_of :address }
    it { should allow_mass_assignment_of :neighbourhood }
    it { should allow_mass_assignment_of :zipcode }
    it { should allow_mass_assignment_of :total_attendees }
    it { should allow_mass_assignment_of :payment_agreement }
    it { should allow_mass_assignment_of :status_event }

    it { should_not allow_mass_assignment_of :id }
  end

  it_should_trim_attributes RegistrationGroup, :name, :state_inscription, :municipal_inscription, :contact_email,
                                               :contact_name, :phone, :fax, :country, :state, :city, :address,
                                               :neighbourhood, :zipcode

  context "associations" do
    it { should have_many :attendees }
    it { should have_many :payment_notifications }
    it { should have_many(:course_attendances).through(:attendees) }
  end

  context "validations" do
    context "brazilians" do
      subject { FactoryGirl.build(:registration_group) }
      it { should validate_presence_of :name }
      it { should validate_presence_of :contact_email }
      it { should validate_presence_of :contact_name }
      it { should validate_presence_of :phone }
      it { should validate_presence_of :fax }
      it { should validate_presence_of :country }
      it { should validate_presence_of :state }
      it { should validate_presence_of :city }
      it { should validate_presence_of :address }
      it { should validate_presence_of :zipcode }
      it { should validate_presence_of :cnpj }
      it { should validate_presence_of :state_inscription }
      it { should validate_presence_of :municipal_inscription }
      it { should validate_presence_of :total_attendees }
    end

    context "non brazilians" do
      subject {FactoryGirl.build(:registration_group, :country => 'US')}
      it { should_not validate_presence_of :cnpj }
      it { should_not validate_presence_of :state_inscription }
      it { should_not validate_presence_of :municipal_inscription }
      it { should_not validate_presence_of :state }
    end

    xit { should validate_confirmation_of :contact_email }

    it { should ensure_length_of(:name).is_at_most(100) }
    it { should ensure_length_of(:country).is_at_most(100) }
    it { should ensure_length_of(:state).is_at_most(100) }
    it { should ensure_length_of(:city).is_at_most(100) }
    it { should ensure_length_of(:address).is_at_most(300) }
    it { should ensure_length_of(:neighbourhood).is_at_most(100) }
    it { should ensure_length_of(:contact_name).is_at_most(100) }
    it { should ensure_length_of(:zipcode).is_at_most(10) }
    it { should ensure_length_of(:contact_email).is_at_least(6).is_at_most(100) }

    it { should allow_value("user@domain.com.br").for(:contact_email) }
    it { should allow_value("test_user.name@a.co.uk").for(:contact_email) }
    it { should_not allow_value("a").for(:contact_email) }
    it { should_not allow_value("a@").for(:contact_email) }
    it { should_not allow_value("a@a").for(:contact_email) }
    it { should_not allow_value("@12.com").for(:contact_email) }

    it { should allow_value("1234-2345").for(:phone) }
    it { should allow_value("+55 11 5555 2234").for(:phone) }
    it { should allow_value("+1 (304) 543.3333").for(:phone) }
    it { should allow_value("07753423456").for(:phone) }
    it { should_not allow_value("a").for(:phone) }
    it { should_not allow_value("1234-bfd").for(:phone) }
    it { should_not allow_value(")(*&^%$@!").for(:phone) }
    it { should_not allow_value("[=+]").for(:phone) }

    it { should allow_value("1234-2345").for(:fax) }
    it { should allow_value("+55 11 5555 2234").for(:fax) }
    it { should allow_value("+1 (304) 543.3333").for(:fax) }
    it { should allow_value("07753423456").for(:fax) }
    it { should_not allow_value("a").for(:fax) }
    it { should_not allow_value("1234-bfd").for(:fax) }
    it { should_not allow_value(")(*&^%$@!").for(:fax) }
    it { should_not allow_value("[=+]").for(:fax) }

    it { should allow_value("69.103.604/0001-60").for(:cnpj) }
    it { should allow_value("69103604000160").for(:cnpj) }
    it { should_not allow_value("12345").for(:cnpj) }
    it { should_not allow_value("66.666.666/6666-66").for(:cnpj) }
    it { should_not allow_value("66666666666666").for(:cnpj) }

    it { should validate_numericality_of :total_attendees }

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

      it "should notify Airbrake on error" do
        error = StandardError.new('error')
        EmailNotifications.expects(:registration_group_confirmed).with(@registration_group).raises(error)
        Airbrake.expects(:notify).with(error)
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

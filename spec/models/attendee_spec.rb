# encoding: UTF-8
# encoding: utf-8
require 'spec_helper'

describe Attendee do
  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :first_name }
    it { should allow_mass_assignment_of :last_name }
    it { should allow_mass_assignment_of :email }
    it { should allow_mass_assignment_of :email_confirmation }
    it { should allow_mass_assignment_of :organization }
    it { should allow_mass_assignment_of :phone }
    it { should allow_mass_assignment_of :country }
    it { should allow_mass_assignment_of :state }
    it { should allow_mass_assignment_of :city }
    it { should allow_mass_assignment_of :badge_name }
    it { should allow_mass_assignment_of :cpf }
    it { should allow_mass_assignment_of :gender }
    it { should allow_mass_assignment_of :twitter_user }
    it { should allow_mass_assignment_of :address }
    it { should allow_mass_assignment_of :neighbourhood }
    it { should allow_mass_assignment_of :zipcode }
    it { should allow_mass_assignment_of :registration_type_id }
    it { should allow_mass_assignment_of :courses }
    it { should allow_mass_assignment_of :status_event }
    it { should allow_mass_assignment_of :conference_id }
    it { should allow_mass_assignment_of :notes }
    it { should allow_mass_assignment_of :payment_agreement }
    it { should allow_mass_assignment_of :registration_date }
    it { should allow_mass_assignment_of :default_locale }

    it { should_not allow_mass_assignment_of :id }
  end
  
  it_should_trim_attributes Attendee, :first_name, :last_name, :email, :organization, :phone,
                                      :country, :state, :city, :badge_name, :twitter_user,
                                      :address, :neighbourhood, :zipcode, :notes
                                        
  context "virtual attributes" do
    before do
      @csm = Course.find_by_name('course.csm.name')
      @cspo = Course.find_by_name('course.cspo.name')
    end
    
    it "should provide courses from course_attendances" do
      attendee = FactoryGirl.build(:attendee)
      attendee.course_attendances.build(:course => @csm)
      attendee.course_attendances.build(:course => @cspo)

      attendee.courses.should == [@csm, @cspo]
    end
    
    it "should populate course_attendances from course ids" do
      attendee = FactoryGirl.build(:attendee, :courses => [@csm.id, @cspo.id])
      attendee.course_attendances[0].course.should == @csm
      attendee.course_attendances[1].course.should == @cspo
      attendee.course_attendances.size.should == 2
    end
    
    it "should provide courses currently registered from course_attendances" do
      attendee = FactoryGirl.create(:attendee, :courses => [@csm.id])
      attendee.registered_courses.should == [@csm]
      attendee.courses = [@csm.id, @cspo.id]
      attendee.registered_courses.should == [@csm]
    end

    it "should provide new courses" do
      attendee = FactoryGirl.create(:attendee, :courses => [@csm.id])
      attendee.new_courses.should == []
      attendee.courses = [@csm.id, @cspo.id]
      attendee.new_courses.should == [@cspo]
    end
    
    context "twitter user" do
      it "should remove @ from start if present" do
        attendee = FactoryGirl.build(:attendee, :twitter_user => '@agilebrazil')
        attendee.twitter_user.should == 'agilebrazil'
      end

      it "should keep as given if doesnt start with @" do
        attendee = FactoryGirl.build(:attendee, :twitter_user => 'agilebrazil')
        attendee.twitter_user.should == 'agilebrazil'
      end
    end
  end

  context "callbacks" do
    it "should set registration_date to current time if not specified" do
      now = Time.zone.local(2011, 4, 25)
      Time.zone.stubs(:now).returns(now)
      attendee = FactoryGirl.build(:attendee)
      attendee.registration_date.should == now
    end
    
    it "should set URI token after initialized" do
      Attendee.expects(:generate_token).with(:uri_token).returns('abc123')
      attendee = FactoryGirl.build(:attendee)
      attendee.uri_token.should == 'abc123'
    end
  end
  
  context "associations" do
    it { should belong_to :conference }
    it { should belong_to :registration_type }
    it { should belong_to :registration_group }

    it { should have_many :course_attendances }
    it { should have_many :payment_notifications }
  end
  
  context "validations" do
    context "brazilians" do
      subject { FactoryGirl.build(:attendee) }
      it { should validate_presence_of :first_name }
      it { should validate_presence_of :last_name }
      it { should validate_presence_of :email }
      it { should validate_presence_of :phone }
      it { should validate_presence_of :country }
      it { should validate_presence_of :state }
      it { should validate_presence_of :city }
      it { should validate_presence_of :address }
      it { should validate_presence_of :gender }
      it { should validate_presence_of :zipcode }
      it { should validate_presence_of :registration_type_id }
      it { should validate_presence_of :conference_id }
      it { should validate_presence_of :cpf }
      it { should_not validate_presence_of :organization }
    end
    
    context "non brazilians" do
      subject {FactoryGirl.build(:attendee, :country => 'US')}
      it { should_not validate_presence_of :cpf }
      it { should_not validate_presence_of :state }
    end

    context "student" do
      subject {FactoryGirl.build(:attendee, :registration_type_id => 1)}
      it { should validate_presence_of :organization }
    end
        
    should_validate_existence_of :conference, :registration_type
    
    xit { should validate_confirmation_of :email }
    
    it { should ensure_length_of(:first_name).is_at_most(100) }
    it { should ensure_length_of(:last_name).is_at_most(100) }
    it { should ensure_length_of(:badge_name).is_at_most(200) }
    it { should ensure_length_of(:organization).is_at_most(100) }
    it { should ensure_length_of(:country).is_at_most(100) }
    it { should ensure_length_of(:state).is_at_most(100) }
    it { should ensure_length_of(:city).is_at_most(100) }
    it { should ensure_length_of(:address).is_at_most(300) }
    it { should ensure_length_of(:neighbourhood).is_at_most(100) }
    it { should ensure_length_of(:zipcode).is_at_most(10) }
    it { should ensure_length_of(:twitter_user).is_at_most(100) }
    it { should ensure_length_of(:email).is_at_least(6).is_at_most(100) }
    
    it { should allow_value("user@domain.com.br").for(:email) }
    it { should allow_value("test_user.name@a.co.uk").for(:email) }
    it { should_not allow_value("a").for(:email) }
    it { should_not allow_value("a@").for(:email) }
    it { should_not allow_value("a@a").for(:email) }
    it { should_not allow_value("@12.com").for(:email) }

    it { should allow_value("1234-2345").for(:phone) }
    it { should allow_value("+55 11 5555 2234").for(:phone) }
    it { should allow_value("+1 (304) 543.3333").for(:phone) }
    it { should allow_value("07753423456").for(:phone) }
    it { should_not allow_value("a").for(:phone) }
    it { should_not allow_value("1234-bfd").for(:phone) }
    it { should_not allow_value(")(*&^%$@!").for(:phone) }
    it { should_not allow_value("[=+]").for(:phone) }

    it { should allow_value("111.444.777-35").for(:cpf) }
    it { should allow_value("11144477735").for(:cpf) }
    it { should_not allow_value("12345").for(:cpf) }
    it { should_not allow_value("111.111.111-11").for(:cpf) }
    it { should_not allow_value("11111111111").for(:cpf) }
    
    xit { should ensure_inclusion_of(:gender).in_range(Gender.valid_values) }
    
    context "uniqueness" do
      before { FactoryGirl.create(:attendee) }
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should validate_uniqueness_of(:cpf) }
    end
    
    it "should validate that payment agreement is checked on confirmation" do
      attendee = FactoryGirl.build(:attendee, :payment_agreement => false)
      attendee.confirm.should be_false
      attendee.errors[:payment_agreement].should include("deve ser aceito")
    end
    
    context "courses" do
      before do
        @csm = Course.find_by_name('course.csm.name')
        @cspo = Course.find_by_name('course.cspo.name')
        @tdd = Course.find_by_name('course.tdd.name')
        @lean = Course.find_by_name('course.lean.name')
      end

      context "no courses" do
        it "should be allowed" do
          FactoryGirl.build(:attendee, :courses => []).should be_valid
        end
      end
      
      context "single course" do
        it "should allow any combination" do
          FactoryGirl.build(:attendee, :courses => [@csm.id]).should be_valid
          FactoryGirl.build(:attendee, :courses => [@cspo.id]).should be_valid
          FactoryGirl.build(:attendee, :courses => [@tdd.id]).should be_valid
          FactoryGirl.build(:attendee, :courses => [@lean.id]).should be_valid
        end
      end
      
      context "two courses" do
        it "should only allow combining TDD and Lean" do
          FactoryGirl.build(:attendee, :courses => [@tdd.id, @lean.id]).should be_valid
          
          FactoryGirl.build(:attendee, :courses => [@csm.id, @cspo.id]).should_not be_valid
          FactoryGirl.build(:attendee, :courses => [@csm.id, @tdd.id]).should_not be_valid
          FactoryGirl.build(:attendee, :courses => [@csm.id, @lean.id]).should_not be_valid
          FactoryGirl.build(:attendee, :courses => [@cspo.id, @tdd.id]).should_not be_valid
          FactoryGirl.build(:attendee, :courses => [@cspo.id, @lean.id]).should_not be_valid
        end
      end
      
      context "three courses" do
        it "should not be allowed" do
          FactoryGirl.build(:attendee, :courses => [@csm.id, @cspo.id, @tdd.id]).should_not be_valid
          FactoryGirl.build(:attendee, :courses => [@csm.id, @cspo.id, @lean.id]).should_not be_valid
          FactoryGirl.build(:attendee, :courses => [@cspo.id, @tdd.id, @lean.id]).should_not be_valid
        end
      end

      context "four courses" do
        it "should not be allowed" do
          FactoryGirl.build(:attendee, :courses => [@csm.id, @cspo.id, @tdd.id, @lean.id]).should_not be_valid
        end
      end

      context "participants limit" do
        it "should not be allowed" do
          Course.any_instance.expects(:has_reached_limit?).returns(true)
          attendee = FactoryGirl.build(:attendee, :courses => [@csm.id])
          attendee.should_not be_valid
          attendee.errors[:courses].should include(
            I18n.t('activerecord.errors.models.attendee.attributes.courses.limit_reached',
                   :course => I18n.t(@csm.name))
          )
        end
        
        it "should validate only new courses" do
          attendee = FactoryGirl.build(:attendee, :courses => [@tdd.id])
          @tdd.stubs(:has_reached_limit?).returns(true)
          @lean.stubs(:has_reached_limit?).returns(false)
          attendee.courses = [@tdd.id, @lean.id]
          attendee.should be_valid
        end
      end
    end
  end
  
  context "state machine" do
    before(:each) do
      @attendee = FactoryGirl.build(:attendee)
    end
    
    context "State: pending" do
      it "should be the initial state" do
        @attendee.should be_pending
      end
      
      it "should allow paying" do
        @attendee.pay.should be_true
        @attendee.should_not be_pending
        @attendee.should be_paid
      end
      
      it "should allow confirming" do
        @attendee.confirm.should be_true
        @attendee.should_not be_pending
        @attendee.should_not be_paid
      end
    end
    
    context "State: paid" do
      before(:each) do
        @attendee.pay
        @attendee.should be_paid
      end
      
      it "should allow confirming" do
        @attendee.confirm.should be_true
        @attendee.should_not be_paid
        @attendee.should be_confirmed
      end
      
      it "should not allow paying again" do
        @attendee.pay.should be_false
        @attendee.should be_paid
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
      
      it "should not allow paying" do
        @attendee.pay.should be_false
        @attendee.should be_confirmed
      end
    end
    
    context "Transition to confirmed" do
      it "should send confirmation e-mail to attendee" do
        email = stub(:deliver => true)
        EmailNotifications.expects(:registration_confirmed).with(@attendee).returns(email)
        @attendee.confirm
      end
      
      it "should notify Airbrake on error" do
        error = StandardError.new('error')
        EmailNotifications.expects(:registration_confirmed).with(@attendee).raises(error)
        Airbrake.expects(:notify).with(error)
        @attendee.confirm
      end
    end
  end
  
  it "should provide full name" do
    attendee = FactoryGirl.build(:attendee, :first_name => "Danilo", :last_name => "Sato")
    attendee.full_name.should == "Danilo Sato"
  end
  
  it "should be student when RegistrationType is student" do
    attendee = FactoryGirl.build(:attendee, :registration_type_id => 1)
    attendee.should be_student
  end
  
  it "should not be student when RegistrationType is individual" do
    attendee = FactoryGirl.build(:attendee, :registration_type_id => 3)
    attendee.should_not be_student
  end
    
  it "should be male for gender male" do
    attendee = FactoryGirl.build(:attendee, :gender => 'M')
    attendee.should be_male
  end
  
  it "should not be male for gender female" do
    attendee = FactoryGirl.build(:attendee, :gender => 'F')
    attendee.should_not be_male
  end
  
  describe "registration fee" do
    before do
      @date = Time.zone.local(2011, 05, 01, 12, 0, 0)
    end

    it "should calculate registration fee based on registration price and date" do
      attendee = FactoryGirl.build(:attendee, :registration_date => @date)
      attendee.registration_fee.should == 165.00

      attendee = FactoryGirl.build(:attendee, :registration_date => @date, :registration_type => RegistrationType.find_by_title('registration_type.student'))
      attendee.registration_fee.should == 65.00
    end
  
    it "should calculate registration fee based on registration price and courses" do
      attendee = FactoryGirl.build(:attendee, :registration_date => @date, :courses => [Course.find_by_name('course.csm.name').id])
      attendee.registration_fee.should == 165.00 + 990.00

      attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      attendee.registration_fee.should == 65.00 + 990.00
      
      attendee.course_attendances.build(:course => Course.find_by_name('course.tdd.name'))
      attendee.registration_fee.should == 65.00 + 990.00 + 280.00
    end
  end
  
  describe "base price" do
    before do
      @date = Time.zone.local(2011, 04, 10, 12, 0, 0)
    end

    it "should calculate base price based on date" do
      attendee = FactoryGirl.build(:attendee, :registration_date => @date)
      attendee.base_price.should == 165.00

      attendee.registration_date = Time.zone.local(2011, 06, 01, 12, 0, 0)
      attendee.base_price.should == 220.00
    end

    it "should calculate base price based on type" do
      attendee = FactoryGirl.build(:attendee, :registration_date => @date)
      attendee.base_price.should == 165.00

      attendee = FactoryGirl.build(:attendee, :registration_date => @date, :registration_type => RegistrationType.find_by_title('registration_type.student'))
      attendee.base_price.should == 65.00
    end

    it "should calculate base price based on pre-registration" do
      attendee = FactoryGirl.build(:attendee, :registration_date => @date)
      attendee.base_price.should == 165.00

      pre = PreRegistration.new(:email => attendee.email, :used => false)
      pre.save!
      attendee.base_price.should == 130.00
      pre.destroy
    end
  end
  
  describe "pre-registration" do
    before :each do
      @attendee = FactoryGirl.build(:attendee)
    end
    
    it "should not be pre-registered if no pre-registration is found for attendee's email" do
      @attendee.should_not be_pre_registered
    end
    
    it "should not be pre-registered if pre-registration is found but was already used for attendee's email" do
      pre = PreRegistration.new(:email => @attendee.email, :used => true)
      pre.save!      
      @attendee.should_not be_pre_registered
      pre.destroy
    end
    
    it "should be pre-registered if pre-registration is found and wasn't used for attendee's email" do
      pre = PreRegistration.new(:email => @attendee.email, :used => false)
      pre.save!      
      @attendee.should be_pre_registered
      pre.destroy
    end
  end
  
  describe "pre-registered" do
    before :each do
      @attendee = FactoryGirl.build(:attendee)
      @pre = PreRegistration.new(:email => @attendee.email, :used => false)
      @pre.save!
    end
    
    after :each do
      @pre.destroy
    end
    
    it "should calculate registration fee with discount if on pre-registration period" do
      @attendee.registration_date = Time.zone.local(2011, 04, 10, 12, 0, 0)
      @attendee.registration_fee.should == 130.00

      @attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      @attendee.registration_fee.should == 50.00
    end
    
    it "should calculate registration fee with discount on pre-registration but not courses" do
      @attendee.registration_date = Time.zone.local(2011, 04, 10, 12, 0, 0)
      @attendee.courses=[3,4]
      @attendee.registration_fee.should == 130.00 + 560.00

      @attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      @attendee.registration_fee.should == 50.00 + 560.00
    end
    
    it "should calculate regular registration fee if outside of pre-registration period" do
      @attendee.registration_date = Time.zone.local(2011, 05, 10, 12, 0, 0)
      @attendee.registration_fee.should == 165.00

      @attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      @attendee.registration_fee.should == 65.00
    end
  end
  
  describe "courses summary" do
    before do
      @attendee = FactoryGirl.build(:attendee)
      @csm = Course.find_by_name('course.csm.name')
      @cspo = Course.find_by_name('course.cspo.name')
    end
    
    it "should be empty when no courses" do
      @attendee.courses_summary.should be_empty
    end
    
    it "single course should show it's name" do
      @attendee.course_attendances.build(:course => @csm)
      @attendee.courses_summary.should == I18n.t(@csm.name)
    end

    it "multiple courses should show all names" do
      @attendee.course_attendances.build(:course => @csm)
      @attendee.course_attendances.build(:course => @cspo)
      @attendee.courses_summary.should == "#{I18n.t(@csm.name)},#{I18n.t(@cspo.name)}"
    end
  end

  describe "registration periods" do
    context "attendee is pre-registered" do
      before(:each) do
        @attendee = FactoryGirl.build(:attendee, :registration_date => Time.zone.local(2011, 4, 5))
        @pre = PreRegistration.new(:email => @attendee.email, :used => false)
        @pre.save!
      end
      
      after(:each) do
        @pre.destroy
      end
      
      it "should not return pre-registration period for course" do
        @attendee.course_registration_period.should == RegistrationPeriod.find_by_title('registration_period.early_bird')
      end
      
      it "should return pre-registration period for registration" do
        @attendee.registration_period.should == RegistrationPeriod.find_by_title('registration_period.pre_register')
      end
    end
    
    context "attendee not pre-registered" do
      before(:each) do
        @attendee = FactoryGirl.build(:attendee, :registration_date => Time.zone.local(2011, 4, 5))
      end

      it "should return normal period for course" do
        @attendee.course_registration_period.should == RegistrationPeriod.find_by_title('registration_period.early_bird')
      end
      
      it "should return normal period for registration" do
        @attendee.registration_period.should == RegistrationPeriod.find_by_title('registration_period.early_bird')
      end
    end
  end
end

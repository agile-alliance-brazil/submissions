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
    should_allow_mass_assignment_of :registration_type_id
    should_allow_mass_assignment_of :courses
    should_allow_mass_assignment_of :status_event
    should_allow_mass_assignment_of :conference_id
    should_allow_mass_assignment_of :notes
    should_allow_mass_assignment_of :payment_agreement

    should_not_allow_mass_assignment_of :id
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
      attendee = Factory.build(:attendee)
      attendee.course_attendances.build(:course => @csm)
      attendee.course_attendances.build(:course => @cspo)

      attendee.courses.should == [@csm, @cspo]
    end
    
    it "should populate course_attendances from course ids" do
      attendee = Factory.build(:attendee, :courses => [@csm.id, @cspo.id])
      attendee.course_attendances[0].course.should == @csm
      attendee.course_attendances[1].course.should == @cspo
      attendee.course_attendances.size.should == 2
    end
    
    context "twitter user" do
      it "should remove @ from start if present" do
        attendee = Factory.build(:attendee, :twitter_user => '@agilebrazil')
        attendee.twitter_user.should == 'agilebrazil'
      end

      it "should keep as given if doesnt start with @" do
        attendee = Factory.build(:attendee, :twitter_user => 'agilebrazil')
        attendee.twitter_user.should == 'agilebrazil'
      end
    end
  end
  
  context "associations" do
    should_belong_to :conference
    should_belong_to :registration_type
    should_belong_to :registration_group
    
    should_have_many :course_attendances
  end
  
  context "validations" do
    context "brazilians" do
      subject { Factory.build(:attendee) }
      should_validate_presence_of :first_name
      should_validate_presence_of :last_name
      should_validate_presence_of :email
      should_validate_presence_of :phone
      should_validate_presence_of :country
      should_validate_presence_of :state
      should_validate_presence_of :city
      should_validate_presence_of :address
      should_validate_presence_of :gender
      should_validate_presence_of :zipcode
      should_validate_presence_of :registration_type_id
      should_validate_presence_of :conference_id
      should_validate_presence_of :cpf
      should_not_validate_presence_of :organization
    end
    
    context "non brazilians" do
      subject {Factory(:attendee, :country => 'US')}
      should_not_validate_presence_of :cpf
      should_not_validate_presence_of :state
    end

    context "student" do
      subject {Factory(:attendee, :registration_type_id => 1)}
      should_validate_presence_of :organization
    end
        
    should_validate_existence_of :conference, :registration_type
    
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
    should_validate_length_of :email, :within => 6..100, :allow_blank => true
    
    should_allow_values_for :email, "user@domain.com.br", "test_user.name@a.co.uk"
    should_not_allow_values_for :email, "a", "a@", "a@a", "@12.com"
    
    should_allow_values_for :phone, "1234-2345", "+55 11 5555 2234", "+1 (304) 543.3333", "07753423456"
    should_not_allow_values_for :phone, "a", "1234-bfd", ")(*&^%$@!", "[=+]"

    should_allow_values_for :cpf, "111.444.777-35", "11144477735"
    should_not_allow_values_for :cpf, "12345", "111.111.111-11", "11111111111"
    
    should_validate_inclusion_of :gender, :in => Gender.valid_values, :allow_blank => true
    
    context "uniqueness" do
      before { Factory(:attendee) }
      should_validate_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
      should_validate_uniqueness_of :cpf, :allow_blank => true
    end
    
    it "should validate that payment agreement is checked on confirmation" do
      attendee = Factory(:attendee, :payment_agreement => false)
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
          Factory.build(:attendee, :courses => []).should be_valid
        end
      end
      
      context "single course" do
        it "should allow any combination" do
          Factory.build(:attendee, :courses => [@csm.id]).should be_valid
          Factory.build(:attendee, :courses => [@cspo.id]).should be_valid
          Factory.build(:attendee, :courses => [@tdd.id]).should be_valid
          Factory.build(:attendee, :courses => [@lean.id]).should be_valid
        end
      end
      
      context "two courses" do
        it "should only allow combining TDD and Lean" do
          Factory.build(:attendee, :courses => [@tdd.id, @lean.id]).should be_valid
          
          Factory.build(:attendee, :courses => [@csm.id, @cspo.id]).should_not be_valid
          Factory.build(:attendee, :courses => [@csm.id, @tdd.id]).should_not be_valid
          Factory.build(:attendee, :courses => [@csm.id, @lean.id]).should_not be_valid
          Factory.build(:attendee, :courses => [@cspo.id, @tdd.id]).should_not be_valid
          Factory.build(:attendee, :courses => [@cspo.id, @lean.id]).should_not be_valid
        end
      end
      
      context "three courses" do
        it "should not be allowed" do
          Factory.build(:attendee, :courses => [@csm.id, @cspo.id, @tdd.id]).should_not be_valid
          Factory.build(:attendee, :courses => [@csm.id, @cspo.id, @lean.id]).should_not be_valid
          Factory.build(:attendee, :courses => [@cspo.id, @tdd.id, @lean.id]).should_not be_valid
        end
      end

      context "four courses" do
        it "should not be allowed" do
          Factory.build(:attendee, :courses => [@csm.id, @cspo.id, @tdd.id, @lean.id]).should_not be_valid
        end
      end

      context "participants limit" do
        it "should not be allowed" do
          Course.any_instance.expects(:has_reached_limit?).returns(true)
          attendee = Factory.build(:attendee, :courses => [@csm.id])
          attendee.should_not be_valid
          attendee.errors[:courses].should include(
            I18n.t('activerecord.errors.models.attendee.attributes.courses.limit_reached',
                   :course => I18n.t(@csm.name))
          )
        end
      end
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
    attendee = Factory.build(:attendee, :registration_type_id => 1)
    attendee.should be_student
  end
  
  it "should not be student when RegistrationType is individual" do
    attendee = Factory.build(:attendee, :registration_type_id => 3)
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
  
  describe "registration fee" do
    before do
      @date = Time.zone.local(2011, 05, 01, 12, 0, 0)
    end

    it "should calculate registration fee based on registration price and date" do
      attendee = Factory.build(:attendee)
      attendee.registration_fee(@date).should == 165.00

      attendee = Factory.build(:attendee, :registration_type => RegistrationType.find_by_title('registration_type.student'))
      attendee.registration_fee(@date).should == 65.00
    end
  
    it "should calculate registration fee based on registration price and courses" do
      attendee = Factory.build(:attendee, :courses => [Course.find_by_name('course.csm.name').id])
      attendee.registration_fee(@date).should == 165.00 + 990.00

      attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      attendee.registration_fee(@date).should == 65.00 + 990.00
      
      attendee.course_attendances.build(:course => Course.find_by_name('course.tdd.name'))
      attendee.registration_fee(@date).should == 65.00 + 990.00 + 280.00
    end
  end
  
  describe "base price" do
    before do
      @date = Time.zone.local(2011, 04, 10, 12, 0, 0)
    end

    it "should calculate base price based on date" do
      attendee = Factory.build(:attendee)
      attendee.base_price(@date).should == 165.00

      attendee.base_price(Time.zone.local(2011, 06, 01, 12, 0, 0)).should == 220.00
    end
    

    it "should calculate base price based on type" do
      attendee = Factory.build(:attendee)
      attendee.base_price(@date).should == 165.00

      attendee = Factory.build(:attendee, :registration_type => RegistrationType.find_by_title('registration_type.student'))
      attendee.base_price(@date).should == 65.00
    end

    it "should calculate base price based on pre-registration" do
      attendee = Factory.build(:attendee)
      attendee.base_price(@date).should == 165.00

      pre = PreRegistration.new(:email => attendee.email, :used => false)
      pre.save!
      attendee.base_price(@date).should == 130.00
      pre.destroy
    end
  end
  
  context "pre-registration" do
    before :each do
      @attendee = Factory.build(:attendee)
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
      @attendee = Factory.build(:attendee)
      @pre = PreRegistration.new(:email => @attendee.email, :used => false)
      @pre.save!
    end
    
    after :each do
      @pre.destroy
    end
    
    it "should calculate registration fee with discount if on pre-registration period" do
      date = Time.zone.local(2011, 04, 10, 12, 0, 0)
      @attendee.registration_fee(date).should == 130.00

      @attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      @attendee.registration_fee(date).should == 50.00
    end
    
    it "should calculate registration fee with discount on pre-registration but not courses" do
      date = Time.zone.local(2011, 04, 10, 12, 0, 0)
      @attendee.courses=[3,4]
      @attendee.registration_fee(date).should == 130.00 + 560.00

      @attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      @attendee.registration_fee(date).should == 50.00 + 560.00
    end
    
    it "should calculate regular registration fee if outside of pre-registration period" do
      date = Time.zone.local(2011, 05, 10, 12, 0, 0)
      @attendee.registration_fee(date).should == 165.00

      @attendee.registration_type = RegistrationType.find_by_title('registration_type.student')
      @attendee.registration_fee(date).should == 65.00
    end
  end
  
  describe "courses summary" do
    before do
      @attendee = Factory.build(:attendee)
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
end
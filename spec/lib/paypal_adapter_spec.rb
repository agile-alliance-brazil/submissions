# encoding: UTF-8
require 'spec_helper'

describe PaypalAdapter do
  describe "from_attendee" do
    before(:each) do
      @attendee ||= FactoryGirl.create(:attendee, :registration_date => Time.zone.local(2011, 5, 15))
    end
    
    it "should add item for base registration price" do
      adapter = PaypalAdapter.from_attendee(@attendee)

      adapter.items.size.should == 1
      adapter.items[0].amount.should == @attendee.base_price
      adapter.items[0].name.should == "Tipo de inscrição: Individual"
      adapter.items[0].quantity.should == 1
      adapter.items[0].number.should == @attendee.registration_type.id
    end
    
    it "should add items for each course attendance" do
      tdd_course = Course.find_by_name('course.tdd.name')
      @attendee.course_attendances.build(:course => tdd_course)
      lean_course = Course.find_by_name('course.lean.name')
      @attendee.course_attendances.build(:course => lean_course)
      
      adapter = PaypalAdapter.from_attendee(@attendee)
      
      adapter.items.size.should == 3
      adapter.items[1].amount.should == tdd_course.price(@attendee.registration_date)
      adapter.items[1].name.should == "Cursos: TDD"
      adapter.items[1].quantity.should == 1
      adapter.items[1].number.should == tdd_course.id
      
      adapter.items[2].amount.should == lean_course.price(@attendee.registration_date)
      adapter.items[2].name.should == "Cursos: Lean"
      adapter.items[2].quantity.should == 1
      adapter.items[2].number.should == lean_course.id
    end
    
    it "should add invoice type and id" do
      adapter = PaypalAdapter.from_attendee(@attendee)
      adapter.invoice_type.should == 'Attendee'
      adapter.invoice_id.should == @attendee.id
    end
  end
  
  describe "from_registration_group" do
    before(:each) do
      @date = Time.zone.local(2011, 5, 15)
      @registration_group ||= FactoryGirl.create(:registration_group)
      
      @attendee_1 = FactoryGirl.create(:attendee, :registration_date => @date, :registration_group => @registration_group, :registration_type => RegistrationType.find_by_title('registration_type.group'))
      @attendee_2 = FactoryGirl.create(:attendee, :registration_date => @date, :registration_group => @registration_group, :registration_type => RegistrationType.find_by_title('registration_type.group'), :cpf => "366.624.533-15")
    end
    
    it "should add items for each attendee's registration" do
      adapter = PaypalAdapter.from_registration_group(@registration_group)

      adapter.items.size.should == 2
      adapter.items[0].amount.should == @attendee_1.base_price
      adapter.items[0].name.should == "Inscrição: #{@attendee_1.full_name}"
      adapter.items[0].quantity.should == 1
      adapter.items[0].number.should == @attendee_1.registration_type.id

      adapter.items[1].amount.should == @attendee_2.base_price
      adapter.items[1].name.should == "Inscrição: #{@attendee_2.full_name}"
      adapter.items[1].quantity.should == 1
      adapter.items[1].number.should == @attendee_2.registration_type.id
    end
    
    it "should add items for each attendee's course attendances" do
      tdd_course = Course.find_by_name('course.tdd.name')
      @attendee_1.course_attendances.create(:course => tdd_course)
      lean_course = Course.find_by_name('course.lean.name')
      @attendee_2.course_attendances.create(:course => lean_course)
      
      adapter = PaypalAdapter.from_registration_group(@registration_group)

      adapter.items.size.should == 4
      adapter.items[1].amount.should == tdd_course.price(@attendee_1.registration_date)
      adapter.items[1].name.should == "Cursos: #{@attendee_1.full_name} (TDD)"
      adapter.items[1].quantity.should == 1
      adapter.items[1].number.should == tdd_course.id

      adapter.items[3].amount.should == lean_course.price(@attendee_2.registration_date)
      adapter.items[3].name.should == "Cursos: #{@attendee_2.full_name} (Lean)"
      adapter.items[3].quantity.should == 1
      adapter.items[3].number.should == lean_course.id      
    end

    it "should add invoice type and id" do
      adapter = PaypalAdapter.from_registration_group(@registration_group)
      adapter.invoice_type.should == 'RegistrationGroup'
      adapter.invoice_id.should == @registration_group.id
    end
  end
  
  describe "to_variables" do
    it "should map each item's variables" do
      attendee = FactoryGirl.create(:attendee)
      adapter = PaypalAdapter.new([
        PaypalAdapter::PaypalItem.new('item 1', 2, 10.50),
        PaypalAdapter::PaypalItem.new('item 2', 3, 9.99, 2)
      ], attendee)
      
      adapter.to_variables.should include({
        'amount_1' => 10.50,
        'item_name_1' => 'item 1',
        'quantity_1' => 1,
        'item_number_1' => 2,
        'amount_2' => 9.99,
        'item_name_2' => 'item 2',
        'quantity_2' => 2,
        'item_number_2' => 3
      })
    end
    
    it "should add invoice id and custom field for invoice type" do
      attendee = FactoryGirl.create(:attendee)
      adapter = PaypalAdapter.new([
        PaypalAdapter::PaypalItem.new('item 1', 2, 10.50),
        PaypalAdapter::PaypalItem.new('item 2', 3, 9.99, 2)
      ], attendee)

      adapter.to_variables.should include({
        'invoice' => attendee.id,
        'custom' => 'Attendee'
      })
    end
  end
  
  describe PaypalAdapter::PaypalItem do
    it "should have name" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).name.should == 'item'
    end

    it "should have number" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).number.should == 2
    end
    
    it "should have amount" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).amount.should == 10.50
    end
    
    it "should have optional quantity" do
      PaypalAdapter::PaypalItem.new('item', 2, 10.50).quantity.should == 1
      PaypalAdapter::PaypalItem.new('item', 2, 10.50, 3).quantity.should == 3
    end
    
    describe "to_variables" do
      it "should map item name, number, amount, and quantity for given index" do
        item = PaypalAdapter::PaypalItem.new('item', 2, 10.50)
        item.to_variables(1).should == {
          'amount_1' => 10.50,
          'item_name_1' => 'item',
          'quantity_1' => 1,
          'item_number_1' => 2
        }

        item.to_variables(10).should == {
          'amount_10' => 10.50,
          'item_name_10' => 'item',
          'quantity_10' => 1,
          'item_number_10' => 2
        }
      end
    end
  end
end

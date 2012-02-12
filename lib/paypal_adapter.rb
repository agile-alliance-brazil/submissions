# encoding: UTF-8
class PaypalAdapter
  class << self
    def from_attendee(attendee)
      registration_desc = lambda do |attendee|
        "#{I18n.t('formtastic.labels.attendee.registration_type_id')}: #{I18n.t(attendee.registration_type.title)}"
      end
      course_desc = lambda do |attendee, course|
        "#{I18n.t('formtastic.labels.attendee.courses')}: #{I18n.t(course.name)}"
      end
      items = create_items(attendee, registration_desc, course_desc)
      self.new(items, attendee)
    end
    
    def from_registration_group(registration_group)
      registration_desc = lambda do |attendee|
        "#{I18n.t('registration_total.base_price')}: #{attendee.full_name}"
      end
      course_desc = lambda do |attendee, course|
        "#{I18n.t('formtastic.labels.attendee.courses')}: #{attendee.full_name} (#{I18n.t(course.name)})"
      end
      items = registration_group.attendees.map do |attendee|
        create_items(attendee, registration_desc, course_desc)
      end
      self.new(items.flatten, registration_group)
    end
    
    private
    def create_items(attendee, registration_desc, course_desc)
      [].tap do |items|
        items << PaypalItem.new(
          CGI.escapeHTML(registration_desc.call(attendee)),
          attendee.registration_type.id,
          attendee.base_price
        )
        attendee.courses.each do |course|
          items << PaypalItem.new(
            CGI.escapeHTML(course_desc.call(attendee, course)),
            course.id,
            course.price(attendee.registration_date)
          )
        end
      end
    end
  end
  
  attr_reader :items, :invoice_type, :invoice_id
  
  def initialize(items, target)
    @items, @invoice_type, @invoice_id = items, target.class.to_s, target.id
  end
  
  def to_variables
    {}.tap do |vars|
      @items.each_with_index do |item, index|
        vars.merge!(item.to_variables(index+1))
      end
      vars['invoice'] = @invoice_id
      vars['custom'] = @invoice_type
    end
  end
  
  class PaypalItem
    attr_reader :name, :number, :amount, :quantity
    
    def initialize(name, number, amount, quantity = 1)
      @name, @number, @amount, @quantity = name, number, amount, quantity
    end
    
    def to_variables(index)
      {
        "amount_#{index}" => amount,
        "item_name_#{index}" => name,
        "item_number_#{index}" => number,
        "quantity_#{index}" => quantity
      }
    end
  end
  
end

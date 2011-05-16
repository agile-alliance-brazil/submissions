module PaypalHelper
  def paypal_url(attendee, return_url, notify_url)
    values = {  
      :business => AppConfig[:paypal][:email],
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => attendee.id,
      :currency_code => AppConfig[:paypal][:currency],
      :notify_url => notify_url
    }

    # Registration
    values.merge!({
      "amount_1" => @attendee.base_price,
      "item_name_1" => CGI.escapeHTML("#{t('formtastic.labels.attendee.registration_type_id')}: #{t(@attendee.registration_type.title)}"),
      "item_number_1" => @attendee.registration_type.id,
      "quantity_1" => 1
    })
    
    # Courses
    @attendee.courses.each_with_index do |course, index|
      values.merge!({
        "amount_#{index + 2}" => course.price(@attendee.registration_date),
        "item_name_#{index + 2}" => CGI.escapeHTML("#{t('formtastic.labels.attendee.courses')}: #{t(course.name)}"),
        "item_number_#{index + 2}" => course.id,
        "quantity_#{index + 2}" => 1
      })
    end

    AppConfig[:paypal][:url] + "?" + values.to_query
  end
end
module PaypalHelper
  def paypal_params(attendee, return_url, notify_url)
    values = {  
      :business => AppConfig[:paypal][:email],
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :cancel_return => return_url,
      :invoice => attendee.id,
      :currency_code => AppConfig[:paypal][:currency],
      :notify_url => notify_url,
      :cert_id => AppConfig[:paypal][:cert_id]
    }

    # Registration
    values.merge!({
      "amount_1" => attendee.base_price,
      "item_name_1" => CGI.escapeHTML("#{t('formtastic.labels.attendee.registration_type_id')}: #{t(attendee.registration_type.title)}"),
      "item_number_1" => attendee.registration_type.id,
      "quantity_1" => 1
    })
    
    # Courses
    attendee.courses.each_with_index do |course, index|
      values.merge!({
        "amount_#{index + 2}" => course.price(attendee.registration_date),
        "item_name_#{index + 2}" => CGI.escapeHTML("#{t('formtastic.labels.attendee.courses')}: #{t(course.name)}"),
        "item_number_#{index + 2}" => course.id,
        "quantity_#{index + 2}" => 1
      })
    end

    values
  end
  
  def paypal_encrypted(attendee, return_url, notify_url)
    encrypt_for_paypal(paypal_params(attendee, return_url, notify_url))
  end
  
  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
  APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
  APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")
  
  def encrypt_for_paypal(values)
    signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
    OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end
end
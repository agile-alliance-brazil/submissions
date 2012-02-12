# encoding: UTF-8
module PaypalHelper
  def add_config_vars(values, return_url, notify_url)
    values.tap do |vars|
      vars[:business] = AppConfig[:paypal][:email]
      vars[:cmd] = '_cart'
      vars[:upload] = 1
      vars[:return] = return_url
      vars[:cancel_return] = return_url
      vars[:currency_code] = AppConfig[:paypal][:currency]
      vars[:notify_url] = notify_url
      vars[:cert_id] = AppConfig[:paypal][:cert_id]
    end
  end
  
  def paypal_encrypted_attendee(attendee, return_url, notify_url)
    encrypt_for_paypal(
      add_config_vars(
        PaypalAdapter.from_attendee(attendee).to_variables,
        return_url, notify_url
      )
    )
  end

  def paypal_encrypted_registration_group(registration_group, return_url, notify_url)
    encrypt_for_paypal(
      add_config_vars(
        PaypalAdapter.from_registration_group(registration_group).to_variables,
        return_url, notify_url
      )
    )
  end
  
  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
  APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
  APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")
  
  def encrypt_for_paypal(values)
    signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
    OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end
end

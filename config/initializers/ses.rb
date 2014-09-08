# encoding: UTF-8
if AppConfig[:ses]
  ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
        :access_key_id     => AppConfig[:ses][:access_key_id],
        :secret_access_key => AppConfig[:ses][:secret_access_key],
        :server            => AppConfig[:ses][:server]
end

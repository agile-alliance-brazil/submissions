# frozen_string_literal: true

if APP_CONFIG[:ses]
  ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                         access_key_id: APP_CONFIG[:ses][:access_key_id],
                                         secret_access_key: APP_CONFIG[:ses][:secret_access_key]
end

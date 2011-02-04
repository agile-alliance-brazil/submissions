# To fix Stack level too deep error on ActionMailer (Rails 3)
# https://rails.lighthouseapp.com/projects/8994/tickets/5329-using-i18nwith_locale-in-actionmailer-raises-systemstackerror
module AbstractController
  class I18nProxy < ::I18n::Config #:nodoc:
    attr_reader :original_config

    def initialize(original_config, lookup_context)
      original_config = original_config.original_config if original_config.respond_to?(:original_config)
      @original_config, @lookup_context = original_config, lookup_context
    end

    def locale
      @original_config.locale
    end
  end
end

module ActionView
  class LookupContext
    module Details
      def locale=(value)
        if value
          config = I18n.config.respond_to?(:original_config) ? I18n.config.original_config : I18n.config
          config.locale = value
        end

        super(@skip_default_locale ? I18n.locale : _locale_defaults)
      end
    end
  end
end

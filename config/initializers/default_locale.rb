# encoding: UTF-8
# Fix bug:
# https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/5145-i18n-locale-may-be-reset-to-en-if-called-from-a-plugingem
# https://groups.google.com/group/rubyonrails-core/browse_thread/thread/1fe3e88f9fe73177/
#AgileBrazil::Application.config.i18n.default_locale = :pt
I18n.default_locale = :pt

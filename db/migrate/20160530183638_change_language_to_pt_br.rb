# frozen_string_literal: true
class ChangeLanguageToPtBr < ActiveRecord::Migration
  def up
    TranslatedContent.where(language: 'pt').update_all(language: 'pt-BR')

    User.where(default_locale: 'pt').update_all(default_locale: 'pt-BR')
    change_column_default(:users, :default_locale, 'pt-BR')

    Conference.where(supported_languages: 'pt').update_all(supported_languages: 'pt-BR')
    Conference.where(supported_languages: 'en,pt').update_all(supported_languages: 'en,pt-BR')
    Conference.where(supported_languages: 'pt,en').update_all(supported_languages: 'pt-BR,en')
    change_column_default(:conferences, :supported_languages, 'en,pt-BR')

    Session.where(language: 'pt').update_all(language: 'pt-BR')
    Page.where(language: 'pt').update_all(language: 'pt-BR')
    change_column_default(:pages, :language, 'pt-BR')
  end

  def down
    TranslatedContent.where(language: 'pt-BR').update_all(language: 'pt')

    User.where(default_locale: 'pt-BR').update_all(default_locale: 'pt')
    change_column_default(:users, :default_locale, 'pt')

    Conference.where(supported_languages: 'pt-BR').update_all(supported_languages: 'pt')
    Conference.where(supported_languages: 'en,pt-BR').update_all(supported_languages: 'en,pt')
    Conference.where(supported_languages: 'pt-BR,en').update_all(supported_languages: 'pt,en')
    change_column_default(:conferences, :supported_languages, 'en,pt')

    Session.where(language: 'pt-BR').update_all(language: 'pt')

    Page.where(language: 'pt-BR').update_all(language: 'pt')
    change_column_default(:pages, :language, 'pt')
  end
end

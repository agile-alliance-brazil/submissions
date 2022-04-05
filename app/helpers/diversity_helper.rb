# frozen_string_literal: true

module DiversityHelper
  GENDER_VALUES = %i[rather_not_answer cis_man trans_man cis_woman trans_woman non_binary i_dont_know].freeze
  RACE_VALUES = %i[rather_not_answer yellow white indian brown black i_dont_know].freeze
  DISABILITY_VALUES = %i[rather_not_answer no_disability visual hearing physical_or_motor mental_or_intellectual i_dont_know].freeze
  IS_PARENT_VALUES = %i[rather_not_answer yes no].freeze
  HOME_GEOGRAPHICAL_AREA_VALUES = %i[rather_not_answer metropolitan periferic rural indigenous quilombola].freeze

  def gender_options
    options_for(GENDER_VALUES, :gender)
  end

  def translated_gender(value)
    translate_option(value, GENDER_VALUES, :gender)
  end

  def race_options
    options_for(RACE_VALUES, :race)
  end

  def translated_race(value)
    translate_option(value, RACE_VALUES, :race)
  end

  def disability_options
    options_for(DISABILITY_VALUES, :disability)
  end

  def translated_disability(value)
    translate_option(value, DISABILITY_VALUES, :disability)
  end

  def translated_age_range(a_date)
    return '' unless a_date.respond_to?(:beginning_of_day)

    date = a_date.beginning_of_day
    now = DateTime.current.beginning_of_day

    return t('age_range.until_18') if date.advance(years: 19) > now
    return t('age_range.between_19_and_24') if date.advance(years: 25) > now
    return t('age_range.between_25_and_29') if date.advance(years: 30) > now
    return t('age_range.between_30_and_34') if date.advance(years: 35) > now
    return t('age_range.between_35_and_39') if date.advance(years: 40) > now
    return t('age_range.between_40_and_44') if date.advance(years: 45) > now
    return t('age_range.between_45_and_49') if date.advance(years: 50) > now
    return t('age_range.between_50_and_54') if date.advance(years: 55) > now
    return t('age_range.between_55_and_59') if date.advance(years: 60) > now

    '60 anos ou mais'
  end

  def is_parent_options
    options_for(IS_PARENT_VALUES, :is_parent)
  end

  def translated_is_parent(value)
    translate_option(value, IS_PARENT_VALUES, :is_parent)
  end

  def home_geographical_area_options
    options_for(HOME_GEOGRAPHICAL_AREA_VALUES, :home_geographical_area)
  end

  def translated_home_geographical_area(value)
    translate_option(value, HOME_GEOGRAPHICAL_AREA_VALUES, :home_geographical_area)
  end

  private

  def options_for(values, scope)
    values.map { |item| [t(item, scope: scope), item] }
  end

  def translate_option(option, valid_values, scope)
    return '' if option.blank?

    return I18n.translate(option, scope: scope) if valid_values.include?(option.to_sym)

    ''
  end
end

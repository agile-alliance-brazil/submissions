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

  def translated_age_range(a_birth_date)
    return '' unless a_birth_date.respond_to?(:beginning_of_day)

    date = a_birth_date.beginning_of_day
    today = DateTime.current.beginning_of_day

    return t('age_range.until_18') if today.advance(years: -19) < date
    return t('age_range.19_to_24') if today.advance(years: -25) < date
    return t('age_range.25_to_29') if today.advance(years: -30) < date
    return t('age_range.30_to_34') if today.advance(years: -35) < date
    return t('age_range.35_to_39') if today.advance(years: -40) < date
    return t('age_range.40_to_44') if today.advance(years: -45) < date
    return t('age_range.45_to_49') if today.advance(years: -50) < date
    return t('age_range.50_to_54') if today.advance(years: -55) < date
    return t('age_range.55_to_59') if today.advance(years: -60) < date

    t('age_range.60_or_above')
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

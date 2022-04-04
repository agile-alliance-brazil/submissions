# frozen_string_literal: true

module DiversityHelper
  COMMON_OPTIONS = %i[rather_not_answer i_dont_know].freeze
  GENDER_VALUES = %i[cis_man trans_man cis_woman trans_woman non_binary].freeze
  RACE_VALUES = %i[yellow white indian brown black].freeze
  DISABILITIES_VALUES = %i[no_disabilities visual hearing physical_or_motor mental_or_intellectual].freeze

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

  def disabilities_options
    options_for(DISABILITIES_VALUES, :disabilities)
  end

  def translated_disabilities(value)
    translate_option(value, DISABILITIES_VALUES, :disabilities)
  end

  private

  def options_for(values, scope)
    [[t(:rather_not_answer, scope: :generic), :rather_not_answer]] +
      values.map { |item| [t(item, scope: scope), item] } +
      [[t(:i_dont_know, scope: :generic), :i_dont_know]]
  end

  def translate_option(option, valid_values, scope)
    return '' if option.blank?

    return I18n.translate(option, scope: scope) if valid_values.include?(option.to_sym)

    return I18n.translate(option, scope: :generic) if COMMON_OPTIONS.include?(option.to_sym)

    ''
  end
end

# frozen_string_literal: true

module DiversityHelper
  COMMON_OPTIONS = %i[rather_not_answer i_dont_know].freeze
  GENDER_VALUES = %i[cis_man trans_man cis_woman trans_woman non_binary].freeze
  RACE_VALUES = %i[yellow white indian brown black].freeze

  def gender_options
    merge_common_options(GENDER_VALUES.map { |gender| [t(gender, scope: :gender), gender] })
  end

  def translated_gender(gender)
    translate_option(gender, GENDER_VALUES, :gender)
  end

  def race_options
    merge_common_options(RACE_VALUES.map { |race| [t(race, scope: :race), race] })
  end

  def translated_race(race)
    translate_option(race, RACE_VALUES, :race)
  end

  private

  def merge_common_options(values)
    [[t(:rather_not_answer, scope: :generic), :rather_not_answer]] +
      values +
      [[t(:i_dont_know, scope: :generic), :i_dont_know]]
  end

  def translate_option(option, valid_values, scope)
    return '' if option.blank?

    return I18n.translate(option, scope: scope) if valid_values.include?(option.to_sym)

    return I18n.translate(option, scope: :generic) if COMMON_OPTIONS.include?(option.to_sym)

    ''
  end
end

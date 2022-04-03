# frozen_string_literal: true

module DiversityHelper
  GENDER_VALUES = %i[
    cis_man
    trans_man
    cis_woman
    trans_woman
    non_binary
  ].freeze

  def gender_options
    [[t(:rather_not_answer, scope: :generic), :rather_not_answer]] +
      GENDER_VALUES.map { |gender| [t(gender, scope: :gender), gender] } +
      [[t(:i_dont_know, scope: :generic), :i_dont_know]]
  end

  def translated_gender(gender)
    return '' if gender.blank?

    return I18n.translate(gender, scope: :gender) if GENDER_VALUES.include?(gender.to_sym)

    return I18n.translate(gender, scope: :generic) if %i[rather_not_answer i_dont_know].include?(gender.to_sym)

    ''
  end
end

module DiversityHelper
  GENDER_OPTIONS = [
    :cis_man,
    :trans_man,
    :cis_woman,
    :trans_woman,
    :non_binary

  ]

  def gender_options
    [[t('generic.rather_not_answer'), :rather_not_answer]] +
      GENDER_OPTIONS.map { |gender| [t("gender.#{gender}"), gender] } +
      [[t('generic.i_dont_know'), :i_dont_know]]
  end
end

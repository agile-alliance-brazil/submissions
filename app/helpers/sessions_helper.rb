#encoding: utf-8
module SessionsHelper
  def all_durations_for(session_types)
    session_types.map(&:valid_durations).flatten.uniq.sort
  end

  def options_for_durations(session_types)
    all_durations_for(session_types).map do |duration|
      ["#{duration} #{t('generic.minutes')}", duration]
    end
  end

  def durations_to_hide(session_types)
    all_durations = all_durations_for(session_types)
    session_types.inject({}) do |durations_to_hide, session_type|
      hide = (all_durations - session_type.valid_durations)
      hide << nil if session_type.valid_durations.size == 1
      durations_to_hide[session_type.id] = hide.map(&:to_s)
      durations_to_hide
    end
  end

  def duration_mins_hint(session_types)
    session_durations = session_types.map do |session_type|
      valid_durations = session_type.valid_durations.sort.join(" #{I18n.t('generic.or')} ")
      [I18n.t("#{session_type.title}_plural"), "#{valid_durations} #{I18n.t('generic.minutes')}"]
    end
    session_durations[0][0].capitalize! << " " << I18n.t("generic.duration_restriction")
    session_durations.map! { |duration| duration.join(" ") }
    last = session_durations.pop
    session_durations.join(", ") << " " << I18n.t("generic.and") << " " << last << "."
  end

end
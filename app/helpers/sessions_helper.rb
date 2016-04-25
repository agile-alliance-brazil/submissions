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
      [session_type.title.downcase, "#{valid_durations} #{I18n.t('generic.minutes')}"]
    end
    first = session_durations.first
    start = "#{first[0].capitalize} #{I18n.t('generic.duration_restriction')} #{first[1]}"
    middle = session_durations[1..-2].map { |duration| duration.join(' ') }
    last = session_durations.last
    ([start] + middle).join(', ') << ' ' << I18n.t('generic.and') << ' ' << last.join(' ') << '.'
  end

  def options_for_session_types(session_types)
    session_types.map { |type| [type.title, type.id] }
  end
end

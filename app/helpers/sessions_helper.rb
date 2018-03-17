# frozen_string_literal: true

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
    session_types.each_with_object({}) do |session_type, durations_to_hide|
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

  def generate_session_form_config(conference)
    session_type_ids_with_audience_limit = conference.session_types.select(&:needs_audience_limit?).map(&:id).map(&:to_s)
    session_type_ids_with_required_mechanics = conference.session_types.select(&:needs_mechanics?).map(&:id).map(&:to_s)
    track_ids_with_restricted_session_types = {
      '4':  ['', '1', '2'],
      '8':  ['', '4', '5'],
      '13': ['', '9']
    }
    {
      audienceLimitSessions: session_type_ids_with_audience_limit,
      requiredMechanicsSessions: session_type_ids_with_required_mechanics,
      filterSessionTypesByTrack: track_ids_with_restricted_session_types,
      tagLimit: conference.tag_limit
    }.to_json
  end
end

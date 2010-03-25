module ReviewersHelper
  def review_level(preferences, track)
    preference = preferences.select{ |pref| pref.track_id == track.id }.first
    if preference
       preference.audience_level.title
    else
      'reviewer.doesnot_review' 
     end
  end
end
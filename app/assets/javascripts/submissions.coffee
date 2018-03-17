(($)->
  $.submissions = $.submissions || {}
  tags = []

  generateAudienceLimitUpdateFunction = (sessionTypeIdsWithAudienceLimit) ->
    (e) ->
      needsAudienceLimit = $.inArray($(this).val(), sessionTypeIdsWithAudienceLimit) > -1
      toggleAudienceLimit(needsAudienceLimit)

  toggleAudienceLimit = (needsAudienceLimit) ->
    $('#session_audience_limit_input').toggle(needsAudienceLimit)
    if !needsAudienceLimit
      $('#session_audience_limit').val('')
    true

  $.submissions.toggleAudienceLimit = toggleAudienceLimit

  generateRequiredMechanicsUpdateFunction = (sessionTypeIdsWithMechanics) ->
    (e) ->
      needsMechanics = $.inArray($(this).val(), sessionTypeIdsWithMechanics) > -1
      $('#session_mechanics_input').find('label abbr').toggle(needsMechanics)
      true

  loadAlreadySelectedTags = (tagLimit) ->
    commaSeparatedTags = if $('#session_keyword_list').size() > 0 then $('#session_keyword_list').get(0).value else ''
    tags = if commaSeparatedTags.length == 0 then [] else commaSeparatedTags.split(',')
    for tag in tags
      tagItem = $('li[data-tag="'+tag+'"]').get(0)
      $(tagItem).addClass('selectedTag')
    $('#tagCounter').text(tagLimit - tags.length)

  filterSessionTypeBasedOnTrack = (trackToSessionTypesLimitations) ->
    $('#session_session_type_id').filterOn('#session_track_id', trackToSessionTypesLimitations)

  $.submissions.initializeSessionProposalForm = (config) ->
    filterSessionTypeBasedOnTrack(config.filterSessionTypesByTrack)
    $('#session_track_id').bindSelectUpdated()

    $('#session_duration_mins').filterOn('#session_session_type_id', $('#session_session_type_id').data('durations-to-hide'))
    $('#session_session_type_id').bindSelectUpdated()

    $('#session_session_type_id').bind('updated', generateAudienceLimitUpdateFunction(config.audienceLimitSessions))
    $('#session_session_type_id').bind('updated', generateRequiredMechanicsUpdateFunction(config.requiredMechanicsSessions))
    $('#session_session_type_id').bindSelectUpdated()

    $('#session_session_type_id, #session_track_id').trigger('updated')

    $('#session_title').charCount({allowed: 100})
    loadAlreadySelectedTags(config.tagLimit)
    $('#session_target_audience').charCount({allowed: 200})
    $('#session_prerequisites').charCount({allowed: 200})
    $('#session_summary').charCount({allowed: 800})
    $('#session_description').charCount({allowed: 2400})
    $('#session_mechanics').charCount({allowed: 2400})
    $('#session_benefits').charCount({allowed: 400})
    $('#session_experience').charCount({allowed: 400})

    $('form.session .tags li').click (e) ->
      newTag = $(e.currentTarget).data('tag')
      index = tags.indexOf(newTag)
      if (index == -1)
        if tags.length >= 10
          $('#tagList .warning').addClass('show')
          return
        tags.push(newTag)
      else
        tags.splice(index, 1)
        $('#tagList .warning').removeClass('show')
      $(e.currentTarget).toggleClass('selectedTag', index == -1)

      $('#session_keyword_list').val tags.join(',')
      $('#tagCounter').text(config.tagLimit - tags.length)

    $('select, input').on 'focus', (e) ->
      $('.inline-hints').hide()
      $(this).parent().find('.inline-hints').show()

    $('textarea').on 'focus', (e) ->
      $('.inline-hints').hide()
      $(this).parent().parent().parent().find('.inline-hints').show()
)(jQuery);

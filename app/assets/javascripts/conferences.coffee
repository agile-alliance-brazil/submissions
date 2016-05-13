#= require jquery

(($) ->
  $.submissions = $.submissions || {}

  isInteger = (val) ->
    $.isNumeric(val) && Math.floor(val) == val

  isValidNewDuration = (elem) ->
    val = parseInt(elem.val(), 10)
    vals = elem.parents('.durations').find('.duration').map (idx, e) ->
      parseInt($(e).val(), 10)
    $.trim(val) && isInteger(val) && ($.inArray(val, vals) < 0)

  addDuration = (button) ->
    parent = button.parents('.durations')
    input = parent.find('.duration_input')
    if isValidNewDuration(input)
      template = parent.find('.duration_template')
      newCheckbox = template.clone()
      newCheckbox.addClass('new_duration')
      newCheckbox.removeClass('duration_template')
      newInput = newCheckbox.find('input')
      val = input.val()
      newInput.attr('id', newInput.attr('id').replace(/duration$/, val))
      newInput.val(val)
      newInput.attr('checked', 'true')
      newCheckbox.text (idx, c) ->
        c.replace '%duration', val
      newCheckbox.prepend(newInput)

      newCheckbox.insertBefore(template)
      input.val ''
    else
      console.log('handle invalid input')
      input.val ''
    button.attr('disabled', !isValidNewDuration(input))

  readURL = (input) ->
    if (input.files && input.files[0])
      reader = new FileReader()
      reader.onload = (e) ->
        $(input).siblings('.image_preview').attr('src', e.target.result)
      reader.readAsDataURL(input.files[0])

  tags = []
  loadAlreadySelectedTags = () ->
    tag_list = $('#conference_tag_list')
    return if tag_list.size() == 0
    commaSeparatedTags = $('#conference_tag_list').get(0).value
    tags = if commaSeparatedTags.length == 0 then [] else commaSeparatedTags.split(',')
    for tag in tags
      tagItem = $('li[data-tag="' + tag + '"]').get(0)
      $(tagItem).addClass('selectedTag')

  updateScrolledClass = (navigation) ->
    tabWindow = navigation.children('ul')
    isScrollable = tabWindow.get(0).scrollWidth > tabWindow.width()
    navigation.toggleClass('with-scroll', isScrollable)

  markAsDirty = (e) ->
    parentForm = $(this).parents('form.tabs')
    container = parentForm.parents('.tabs').children('.navigation-container')
    activeTab = container.children('ul').find('.ui-tabs-active')
    activeTab.addClass('dirty')

  clearDirtyMark = (e, data, status, xhr) ->
    container = $(this).parents('.tabs').children('.navigation-container')
    activeTab = container.children('ul').find('.ui-tabs-active')
    activeTab.removeClass('dirty')

  setMaxDate = (input, date, daysDelta) ->
    newMax = new Date(date.setDate(date.getDate() + daysDelta))
    if input.hasClass('hasDatepicker')
      max = input.datepicker('option', 'maxDate')
      if (!max? || daysDelta == -1 || max > newMax)
        input.datepicker('option', 'maxDate', newMax)
    else
      max = input.attr('max')
      if (!max? || daysDelta == -1 || Date.parse(max) > newMax)
        input.attr('max', [
            newMax.getFullYear(),
            ('0' + (newMax.getMonth() + 1)).slice(-2),
            ('0' + newMax.getDate()).slice(-2)
          ].join('-'))

  setMinDate = (input, date, daysDelta) ->
    newMin = new Date(date.setDate(date.getDate() + daysDelta))
    if input.hasClass('hasDatepicker')
      min = input.datepicker('option', 'minDate')
      if (!min? || daysDelta == 1 || min < newMin)
        input.datepicker('option', 'minDate', newMin)
    else
      min = input.attr('min')
      if (!min? || daysDelta == 1 || Date.parse(min) < newMin)
        input.attr('min', [
            newMin.getFullYear(),
            ('0' + (newMin.getMonth() + 1)).slice(-2),
            ('0' + newMin.getDate()).slice(-2)
          ].join('-'))

  updateDateLimits = (currentInput) ->
    currentIndex = parseInt(currentInput.attr('dateindex'), 10)
    currentDate = Date.parse(currentInput.val())
    $('.conference_date').each (index, input) ->
      otherIndex = parseInt($(input).attr('dateindex'), 10)
      if (otherIndex < currentIndex)
        setMaxDate($(input), new Date(currentDate), otherIndex - currentIndex)
      else if (otherIndex > currentIndex)
        setMinDate($(input), new Date(currentDate), otherIndex - currentIndex)

  fieldFocus = (form) ->
    form.find(':input:visible:enabled:first').focus()

  typingTimeout = 1000
  promise = null

  issueTextilizeRequest = (content, preview) ->
    () ->
      $.ajax({
        url: '/api/textilize',
        method: 'POST',
        data: content,
        dataType: 'html',
        success: (data, status, xhr) ->
          preview.html(data)
      })

  triggerPreviewUpdate = (e) ->
    clearTimeout(promise) if promise?
    preview = $(this).parents('.description').children('.preview')
    content = $(this).val()
    issueTextilizeRequest(content, preview)()

  updatePreview = (e) ->
    clearTimeout(promise) if promise?

    preview = $(this).parents('.description').children('.preview')
    content = $(this).val()
    promise = setTimeout(issueTextilizeRequest(content, preview), typingTimeout)


  $(document).ready () ->
    orderedDates = $('.conference_date').sort((a, b) ->
      aIndex = parseInt($(a).attr('dateindex'), 10)
      bIndex = parseInt($(b).attr('dateindex'), 10)
      aIndex - bIndex
    )
    orderedDates.each (idx, e) ->
      currentInput = $(e)
      updateDateLimits(currentInput)

    $('.conference_date').on 'change', (e) ->
      updateDateLimits($(this))

    $('#session_types .durations .new_duration .add_other_duration').click (e) ->
      button = $(this)
      return false if button.is(':disabled')
      addDuration(button);

    $('#session_types .durations .new_duration .add_other_duration').each (idx, d) ->
      button = $(d)
      input = button.parents('.new_duration').find('.duration_input')
      button.attr('disabled', !isValidNewDuration(input))

    $('#session_types .durations .new_duration .duration_input').bind 'propertychange change click keyup input paste', (e) ->
      input = $(this)
      button = input.parents('.new_duration').find('.add_other_duration')
      button.attr('disabled', !isValidNewDuration(input))

    if !Modernizr.inputtypes.date
      $('input[type="date"]').datepicker(dateFormat: "yy-mm-dd")

    $('.tabs').tabs()
    $('.tabs').tabs(activate: (event, ui) -> fieldFocus($(this)))

    $(".image_field").change () -> readURL(this)

    loadAlreadySelectedTags()

    $('.tags li').click (e) ->
      newTag = $(e.currentTarget).data('tag')
      index = tags.indexOf(newTag)
      if (index == -1)
        tags.push(newTag)
        $(e.currentTarget).addClass('selectedTag')
      else
        tags.splice(index, 1)
        $(e.currentTarget).removeClass('selectedTag')
      $('#conference_tag_list').val(tags.join(','))

    $('.tabs').each (idx, e, arr) ->
      navigation = $(e).children('.navigation-container')
      if navigation.size() > 0
        updateScrolledClass(navigation)
        toFocusOn = navigation.children('ul').find('.ui-tabs-active')
        scrollable = $(e).children('.scrolled').children('ul')
        scrollable.scrollLeft(scrollable.scrollLeft() + toFocusOn.position().left)

    $('.tabs .navigation-container .scroll_left').click (e) ->
      target = $(this).siblings('ul')
      scrollLength = target.width() * 0.9
      targetScroll = target.scrollLeft() - scrollLength
      target.animate scrollLeft: targetScroll

    $('.tabs .navigation-container .scroll_right').click (e) ->
      target = $(this).siblings('ul')
      scrollLength = target.width() * 0.9
      targetScroll = target.scrollLeft() + scrollLength
      target.animate scrollLeft: targetScroll

    $('form.tabs.translated_contents.new').on 'ajax:success', (e, data, status, xhr) ->
      $(this).find('ul li:first-child a').click()
      $(this).find('input[type="text"],textarea').val('')
      $(this).find('input[type="checkbox"]').removeAttr('checked')
      $(this).find('input[type="radiobox"]').prop('checked', false)
      $(this).find('.preview').html('')
      titleToShow = data.translations[0].title
      typeName = $(this).data('typename')
      newLi = '<li class="'+typeName+'"><a href="#'+typeName+'-'+data.id+'">'+titleToShow+'</a></li>'
      $('.'+typeName+'s .add_tab').before(newLi)
      newTab = $('#'+typeName+'-new').clone()
      newTab.attr('id', typeName + '-' + data.id)
      newTab.addClass('track_tab')
      f = newTab.find('form.tabs.translated_contents.new')
      f.removeClass('new').addClass('old')
      data.translations.forEach (e, idx, arr) ->
        languageLink = newTab.find('.'+typeName+'_language.'+e.language.code+' a')
        languageLink.attr('href', languageLink.attr('href').replace('--', '-' + data.id + '-'))

        languageTab = newTab.find('.'+typeName+'_language_tab.' + e.language.code)
        languageTab.attr('id', languageTab.attr('id').replace('--', '-' + data.id + '-'))

        languageTab.find('.field input').val e.title

        descriptionArea = languageTab.find '.description textarea'
        descriptionArea.val e.description

        languageTab.prepend('<input id="' + typeName + '_translated_contents_attributes_' +
          idx + '_id" value="' + e.id + '" name="' + typeName +
          '[translated_contents_attributes][' + idx + '][id]" type="hidden"/>')

      f.attr('id', 'edit_'+typeName+'_'+data.id)
      f.attr('action', f.attr('action').replace(/([^.]+)(\.json)/g, '$1/'+data.id+'$2'))
      f.prepend('<input name="_method" value="patch" type="hidden"/>')

      submitButton = f.find('input[type="submit"]')
      actionText = submitButton.data('update-action')
      f.find('input[type="submit"]').val(actionText)
      f.find(':input').change(markAsDirty)
      f.tabs()
      f.on('ajax:success', clearDirtyMark)
      $('#'+typeName+'-new').before(newTab)

      $('#'+typeName+'s.tabs').tabs('refresh')
      toFocusOn = $('ul.'+typeName+'s>li.'+typeName+':not(.add_tab)').last()
      updateScrolledClass($('#'+typeName+'s>.navigation-container'))
      scrollable = $('.with-scroll .'+typeName+'s')
      scrollable.scrollLeft(scrollable.scrollLeft() + toFocusOn.position().left)
      toFocusOn.find('a').click()

    $('form.tabs.translated_contents.old :input').change markAsDirty
    $('form.tabs.translated_contents.old').on 'ajax:success', clearDirtyMark

    $('.description textarea.value,.description input.value').bind(
      'propertychange change click keyup input paste', updatePreview)
    $('.description textarea.value,.description input.value').bind('blur', triggerPreviewUpdate)

    $('#new_session_type').on 'ajax:success', (e, data, status, xhr) ->
      id = data.id
      conference_visible = $('form.conference').data('visible')
      $('#edit_session_type_'+id+' .durations input[type="checkbox"]').each (idx, c) ->
        value = parseInt($(c).val(), 10)
        $(c).prop('checked', data.valid_durations.indexOf(value) >= 0)
        $(c).prop('disabled', conference_visible)
      $('#edit_session_type_'+id+' .durations .duration_input').prop('disabled', conference_visible)
      $('#edit_session_type_'+id+' .durations .add_other_duration').prop('disabled', conference_visible)

    $('#new_page').on 'ajax:success', (e, data, status, xhr) ->
      id = data.id
      $('#edit_page_'+id+' input.path[type="text"]').val(data.path)
      $('#edit_page_'+id+' input.path[type="text"]').prop('disabled', true)
      $('#edit_page_'+id+' input.show_in_menu[type="checkbox"]').prop('checked', data.show_in_menu)
      fieldFocus($(this))

    $('form.tabs.translated_contents').on 'ajax:error', (e, xhr, status, error) ->
      $(this).append('<p>ERROR: '+error+'</p>')
      $(this).append('<p>STATUS: '+status+'</p>')
      $(this).append('<p>E: '+e+'</p>')
)(jQuery)

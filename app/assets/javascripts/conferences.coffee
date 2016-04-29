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

  $(document).ready () ->
    $('#session_types .durations .new_duration .add_other_duration').click (e) ->
      button = $(this)
      return false if button.is(':disabled')

      parent = button.parents('.durations')
      input = parent.find('.duration_input')
      if isValidNewDuration(input)
        val = input.val()
        template = parent.find('.duration_template')
        newCheckbox = template.clone()
        newCheckbox.removeClass('duration_template')
        newInput = newCheckbox.find('input')
        newInput.attr('id', newInput.attr('id').replace(/duration$/, val))
        newInput.val(val)
        newInput.attr('checked', 'true')
        newCheckbox.text (idx, c) ->
          c.replace('%duration', val)
        newCheckbox.prepend(newInput)
        
        newCheckbox.insertBefore(template)
        input.val('')
      else
        console.log('handle invalid input')
        input.val('')
      button.attr('disabled', !isValidNewDuration(input))

    $('#session_types .durations .new_duration .add_other_duration').each (idx, d) ->
      button = $(d)
      input = button.parents('.new_duration').find('.duration_input')
      button.attr('disabled', !isValidNewDuration(input))

    $('#session_types .durations .new_duration .duration_input').bind 'propertychange change click keyup input paste', (e) ->
      input = $(this)
      button = input.parents('.new_duration').find('.add_other_duration')
      button.attr('disabled', !isValidNewDuration(input))

)(jQuery)

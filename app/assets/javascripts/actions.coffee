#= require jquery
#= require_self
(($) ->
  $.submissions = $.submissions || {}

  $.submissions.initializeCharts = (charts) ->

    drawCharts = ->
      $.each charts, (key, value) ->
        data = google.visualization.arrayToDataTable(value.data)
        options =
          pieSliceText: "none"
          colors: value.colors
          pieHole: 0.4
          legend: "none"
        target = $("#" + key)
        title = target.prev('h4')
        target.show()
        chart = new google.visualization.PieChart(target[0])
        chart.draw data, options
        title.show()

    $.ajax
      url: "//www.google.com/jsapi"
      dataType: "script"
      cache: true
      timeout: 3000
      success: ->
        google.load "visualization", "1",
          packages: ["corechart"]
          callback: drawCharts
)(jQuery)
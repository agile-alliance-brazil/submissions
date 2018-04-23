#= require jquery

(($) ->
  $.submissions = $.submissions || {}

  $.submissions.initializeSubmissionsCharts = (data) ->
    drawCharts = ->
      headers = [].concat([ 'Data submissão' ], data.map((conf) -> "" + conf.year))
      dataPoints = data.map((conf) -> conf.accumulated_distribution)
      dataArray = [ headers ]
      i = 0
      while i < dataPoints[0].length
        dataRow = [ '' ]
        j = 0
        while j < dataPoints.length
          dataRow.push dataPoints[j][i]
          j++
        dataArray.push dataRow
        i++
      dataTable = google.visualization.arrayToDataTable(dataArray)
      options =
        title: 'Submissões ao longo do tempo'
        curveType: 'function'
        legend: position: 'bottom'
      chart = new (google.visualization.LineChart)($('#submissions_curve_chart')[0])
      chart.draw dataTable, options

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

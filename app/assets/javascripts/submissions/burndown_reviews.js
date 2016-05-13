(function($){
  $(document).ready(function() {
    var el = $('#burndown_container');
    if (el.size() === 0 || !el.highcharts) {
      return true;
    }

    el.highcharts({
      chart: {
        height: 200,
        width: 230
      },
      title: {
        align: 'left',
        style: {'font-size': '15px', 'font-weight': 'bold', 'font-family': 'Helvetica Neue'},
        text: 'Reviews burndown',
        x: 0
      },
      colors: ['blue', 'red'],
      plotOptions: {
        line: {
          lineWidth: 1
        },
        tooltip: {
          hideDelay: 200
        }
      },
      xAxis: {
        visible: false
      },
      yAxis: {
        title: {
          text: 'Reviews'
        },
        plotLines: [{
          value: 0,
          width: 1
        }],
        labels: {
          enabled: false
        }
      },
      tooltip: {
        valueSuffix: ' reviews',
        crosshairs: true,
        shared: true
      },
      legend: {
        enabled: false
      },
      series: [{
        name: 'Ideal Remaining Work',
        color: 'rgba(255,0,0,0.25)',
        lineWidth: 1,
        marker: {
          radius: 2
        },
        data: el.data('ideal')
      }, {
        name: 'Actual Remaining Work',
        color: 'rgba(0,120,200,0.75)',
        marker: {
          radius: 2
        },
        data: el.data('actual')
      }]
    });
  });
})(jQuery);

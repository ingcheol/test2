<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #container{
    width:500px;
    border: 2px solid red;
  }
</style>
<script>
chart4={
  url:'https://127.0.0.1:8443/logs/maininfo.log',
  init:function(){
    this.createChart();
  },
  createChart:function(){
    Highcharts.chart('container', {
      chart: {
        type: 'areaspline'
      },
      lang: {
        locale: 'en-GB'
      },
      title: {
        text: 'Live Data'
      },
      accessibility: {
        announceNewData: {
          enabled: true,
          minAnnounceInterval: 15000,
          announcementFormatter: function (
                  allSeries,
                  newSeries,
                  newPoint
          ) {
            if (newPoint) {
              return 'New point added. Value: ' + newPoint.y;
            }
            return false;
          }
        }
      },
      plotOptions: {
        areaspline: {
          color: '#32CD32',
          fillColor: {
            linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },
            stops: [
              [0, '#32CD32'],
              [1, '#32CD3200']
            ]
          },
          threshold: null,
          marker: {
            lineWidth: 1,
            lineColor: null,
            fillColor: 'white'
          }
        }
      },
      data: {
        csvURL: this.url,
        enablePolling: true,
        dataRefreshRate: parseInt(2, 10)
      }
    });
  }
}
$(()=>{
  chart4.init();
})
</script>
<div class="col-sm-10">
  <h2>Chart4</h2>
  <div id="container"></div>
</div>






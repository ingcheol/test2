<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #container{
    width:500px;
    border: 2px solid red;
  }
</style>
<script>
  chart1 = {
    init:function(){
      this.getdata();
      setInterval(()=>{
        this.getdata();
      },4000);
    },
    getdata:function(){
      $.ajax({
        url:'<c:url value="/chart1"/>',
        success:(data)=>{
          this.display(data);
        }
      });
    },
    display:function(data){
      Highcharts.chart('container', {
        chart: {
          type: 'line'
        },
        title: {
          text: 'Monthly Average Temperature!'
        },
        subtitle: {
          text: 'Source: ' +
                  '<a href="https://en.wikipedia.org/wiki/List_of_cities_by_average_temperature" ' +
                  'target="_blank">Wikipedia.com</a>'
        },
        xAxis: {
          categories: [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep',
            'Oct', 'Nov', 'Dec'
          ]
        },
        yAxis: {
          title: {
            text: 'Temperature (°C)'
          }
        },
        plotOptions: {
          line: {
            dataLabels: {
              enabled: true
            },
            enableMouseTracking: false
          }
        },
        series: data
      });
    }
  }
  $(function(){
    chart1.init();
  });
</script>

<div class="col-sm-10">
  <h2>Chart1</h2>
  <div id="container"></div>

</div>

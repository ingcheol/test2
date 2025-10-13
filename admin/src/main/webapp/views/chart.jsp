<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    #container{
        width:auto;
        height: 400px;
        border: 2px solid red;
    }
    #pieContainer{
        width:auto;
        height: 400px;
        border: 2px solid blue;
    }
    #hourlyContainer{
        width:auto;
        height: 400px;
        border: 2px solid green;
    }
    #dailyTrendContainer{
        width:auto;
        height: 400px;
        border: 2px solid orange;
    }
</style>
<script>
    let chart={
        mapClickUrl:'/logs/mapclick',
        init:function(){
            this.createMapClickChart();
            this.createRegionPieChart();
            this.createHourlyChart();
            this.createDailyTrendChart();
        },

        // 막대 차트: 장소별 클릭 횟수
        createMapClickChart:function(){
            var self = this;

            fetch(this.mapClickUrl)
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let clickCount = {};

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let name = parts[2].trim();
                            clickCount[name] = (clickCount[name] || 0) + 1;
                        }
                    });

                    let categories = [];
                    let chartData = [];

                    for(let key in clickCount) {
                        if(clickCount.hasOwnProperty(key)) {
                            categories.push(key);
                            chartData.push(clickCount[key]);
                        }
                    }

                    Highcharts.chart('container', {
                        chart: { type: 'column' },
                        title: { text: '장소별 마커 클릭 횟수' },
                        xAxis: {
                            categories: categories,
                            title: { text: '장소' }
                        },
                        yAxis: {
                            min: 0,
                            title: { text: '클릭 횟수' },
                            allowDecimals: false
                        },
                        plotOptions: {
                            column: {
                                dataLabels: { enabled: true },
                                colorByPoint: true
                            }
                        },
                        series: [{
                            name: '클릭 횟수',
                            data: chartData
                        }],
                        credits: { enabled: false }
                    });
                })
                .catch(error => {
                    console.error('Error loading map click log:', error);
                });
        },

        // 파이 차트: 시/군/구별 클릭 비율
        createRegionPieChart:function(){
            var self = this;

            fetch(this.mapClickUrl)
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let regionCount = {};

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let fullRegion = parts[1].trim();

                            // 시 단위 추출
                            let cityMatch = fullRegion.match(/([가-힣]+시|[가-힣]+군|[가-힣]+구)/);
                            let region = cityMatch ? cityMatch[0] : fullRegion;

                            regionCount[region] = (regionCount[region] || 0) + 1;
                        }
                    });

                    let pieData = [];
                    for(let key in regionCount) {
                        if(regionCount.hasOwnProperty(key)) {
                            pieData.push({
                                name: key,
                                y: regionCount[key]
                            });
                        }
                    }

                    Highcharts.chart('pieContainer', {
                        chart: { type: 'pie' },
                        title: { text: '시/군/구별 클릭 비율' },
                        tooltip: {
                            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b><br>클릭: <b>{point.y}회</b>'
                        },
                        plotOptions: {
                            pie: {
                                allowPointSelect: true,
                                cursor: 'pointer',
                                dataLabels: {
                                    enabled: true,
                                    format: '<b>{point.name}</b>: {point.percentage:.1f}%'
                                },
                                showInLegend: true
                            }
                        },
                        series: [{
                            name: '비율',
                            colorByPoint: true,
                            data: pieData
                        }],
                        credits: { enabled: false }
                    });
                })
                .catch(error => {
                    console.error('Error loading map click log:', error);
                });
        },

        // 시간대별 클릭 분포
        createHourlyChart:function(){
            var self = this;

            fetch(this.mapClickUrl)
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let hourlyCount = {};

                    // 0-23시 초기화
                    for(let i = 0; i < 24; i++) {
                        hourlyCount[i] = 0;
                    }

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let dateStr = parts[0].trim();
                            let hour = parseInt(dateStr.split(' ')[1].split(':')[0]);
                            hourlyCount[hour] = (hourlyCount[hour] || 0) + 1;
                        }
                    });

                    let categories = [];
                    let chartData = [];

                    for(let i = 0; i < 24; i++) {
                        categories.push(i + '시');
                        chartData.push(hourlyCount[i]);
                    }

                    Highcharts.chart('hourlyContainer', {
                        chart: { type: 'areaspline' },
                        title: { text: '시간대별 클릭 분포' },
                        xAxis: {
                            categories: categories,
                            title: { text: '시간대' }
                        },
                        yAxis: {
                            min: 0,
                            title: { text: '클릭 횟수' },
                            allowDecimals: false
                        },
                        tooltip: {
                            shared: true,
                            valueSuffix: '회'
                        },
                        plotOptions: {
                            areaspline: {
                                fillOpacity: 0.5
                            }
                        },
                        series: [{
                            name: '클릭 횟수',
                            data: chartData,
                            color: '#7cb5ec'
                        }],
                        credits: { enabled: false }
                    });
                })
                .catch(error => {
                    console.error('Error loading hourly chart:', error);
                });
        },

        // 일별 트렌드 차트
        createDailyTrendChart:function(){
            var self = this;

            fetch(this.mapClickUrl)
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let dailyCount = {};

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let dateStr = parts[0].trim();
                            let date = dateStr.split(' ')[0];
                            dailyCount[date] = (dailyCount[date] || 0) + 1;
                        }
                    });

                    // 날짜 정렬
                    let dates = Object.keys(dailyCount).sort();
                    let chartData = dates.map(function(date) {
                        return dailyCount[date];
                    });

                    Highcharts.chart('dailyTrendContainer', {
                        chart: { type: 'line' },
                        title: { text: '일별 클릭 추이' },
                        xAxis: {
                            categories: dates,
                            title: { text: '날짜' }
                        },
                        yAxis: {
                            min: 0,
                            title: { text: '클릭 횟수' },
                            allowDecimals: false
                        },
                        tooltip: {
                            valueSuffix: '회'
                        },
                        plotOptions: {
                            line: {
                                dataLabels: { enabled: true },
                                enableMouseTracking: true
                            }
                        },
                        series: [{
                            name: '일별 클릭',
                            data: chartData,
                            color: '#90ed7d'
                        }],
                        credits: { enabled: false }
                    });
                })
                .catch(error => {
                    console.error('Error loading daily trend chart:', error);
                });
        }
    }

    $(()=>{
        chart.init();

        // 10초마다 차트 갱신
        setInterval(function(){
            chart.createMapClickChart();
            chart.createRegionPieChart();
            chart.createHourlyChart();
            chart.createDailyTrendChart();
        }, 10000);
    })
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Map Click Analytics</h1>
        <a href="#" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                class="fas fa-download fa-sm text-white-50"></i> Generate Report</a>
    </div>

    <div class="row">
        <!-- Column Chart -->
        <div class="col-xl-8 col-lg-7">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">장소별 마커 클릭 횟수</h6>
                </div>
                <div class="card-body">
                    <div id="container"></div>
                </div>
            </div>
        </div>

        <!-- Pie Chart -->
        <div class="col-xl-4 col-lg-5">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">시/군/구별 클릭 비율</h6>
                </div>
                <div class="card-body">
                    <div id="pieContainer"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- Hourly Chart -->
        <div class="col-xl-6 col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">시간대별 클릭 분포</h6>
                </div>
                <div class="card-body">
                    <div id="hourlyContainer"></div>
                </div>
            </div>
        </div>

        <!-- Daily Trend Chart -->
        <div class="col-xl-6 col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">일별 클릭 추이</h6>
                </div>
                <div class="card-body">
                    <div id="dailyTrendContainer"></div>
                </div>
            </div>
        </div>
    </div>

</div>

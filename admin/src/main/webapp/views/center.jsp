<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 카드 애니메이션 */
    .card {
        transition: all 0.3s ease;
    }
    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2) !important;
    }
    .card:hover .col-auto i {
        animation: rotate 0.6s ease-in-out;
    }
    @keyframes rotate {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    /* 페이드인 효과 */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .fade-in-card {
        animation: fadeIn 0.6s ease-out;
        animation-fill-mode: both;
    }
    .fade-in-card:nth-child(1) { animation-delay: 0.1s; }
    .fade-in-card:nth-child(2) { animation-delay: 0.2s; }
    .fade-in-card:nth-child(3) { animation-delay: 0.3s; }
    .fade-in-card:nth-child(4) { animation-delay: 0.4s; }

    /* 프로그레스 바 */
    .progress-bar {
        transition: width 1s ease-in-out;
    }

    /* 차트 컨테이너 */
    .enhanced-chart-container {
        width: 100%;
        height: 350px;
        margin-bottom: 20px;
    }
    .card-header-gradient {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white !important;
    }
</style>

<script>
    // 숫자 카운트업 애니메이션
    function animateValue(element, start, end, duration) {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const value = Math.floor(progress * (end - start) + start);
            element.textContent = value.toLocaleString();
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }

    let center = {
        adminId:null,
        init:function(){
            <c:if test="${sessionScope.admin.adminId != null}">
            this.adminId = '${sessionScope.admin.adminId}';
            this.connect();
            </c:if>

            // 카드 애니메이션 초기화
            this.initCardAnimations();

            // 차트 초기화
            this.initEnhancedCharts();
        },

        initCardAnimations:function(){
            // 모든 카드에 fade-in 효과
            $('.card').addClass('fade-in-card');

            // 프로그레스 바 애니메이션
            setTimeout(() => {
                $('.progress-bar').each(function() {
                    const targetWidth = $(this).attr('aria-valuenow');
                    $(this).css('width', '0%');
                    setTimeout(() => {
                        $(this).css('width', targetWidth + '%');
                    }, 100);
                });
            }, 500);
        },

        connect:function(){
            let url = '${sseUrl}'+'connect/'+this.adminId ;
            const sse = new EventSource(url);
            sse.addEventListener('connect', (e) => {
                const { data: receivedConnectData } = e;
                console.log('connect event data: ',receivedConnectData);
            });
            sse.addEventListener('aimsg', e => {
                const { data: data } = e;
                console.log("msg :",data);

                const result = JSON.parse(data).result;
                $('#aimsg').html(result.trim());

                const base64Src = "data:image/png;base64," + JSON.parse(data).base64File;
                const generatedImage = document.getElementById("generatedImage");
                generatedImage.src = base64Src;
            });
            sse.addEventListener('count', e => {
                const { data: receivedCount } = e;
                console.log("count :",receivedCount);
                // 카운트업 애니메이션 적용
                const countElement = $('#count')[0];
                const oldValue = parseInt($('#count').text().replace(/[$,]/g, '')) || 0;
                const newValue = parseInt(receivedCount);
                animateValue(countElement, oldValue, newValue, 500);
            });
            sse.addEventListener('adminmsg', e => {
                const { data: receivedData } = e;
                this.display(JSON.parse(receivedData));
            });
        },

        display:function(data){
            // 숫자 애니메이션과 함께 업데이트
            const msg1 = $('#msg1')[0];
            const msg2 = $('#msg2')[0];
            const msg3 = $('#msg3')[0];
            const msg4 = $('#msg4')[0];

            animateValue(msg1, parseInt($('#msg1').text()) || 0, data.content1, 500);
            animateValue(msg2, parseInt($('#msg2').text()) || 0, data.content2, 500);
            animateValue(msg3, parseInt($('#msg3').text()) || 0, data.content3, 500);
            animateValue(msg4, parseInt($('#msg4').text()) || 0, data.content4, 500);

            // 프로그레스 바 애니메이션
            $('#progress1').css('width', '0%');
            setTimeout(() => {
                $('#progress1').css('width', data.content1/100*100+'%');
                $('#progress1').attr('aria-valuenow', data.content1/100*100);
            }, 100);

            $('#progress2').css('width', '0%');
            setTimeout(() => {
                $('#progress2').css('width', data.content2/1000*100+'%');
                $('#progress2').attr('aria-valuenow', data.content2/1000*100);
            }, 200);

            $('#progress3').css('width', '0%');
            setTimeout(() => {
                $('#progress3').css('width', data.content3/500*100+'%');
                $('#progress3').attr('aria-valuenow', data.content3/500*100);
            }, 300);

            $('#progress4').css('width', '0%');
            setTimeout(() => {
                $('#progress4').css('width', data.content4/10*100+'%');
                $('#progress4').attr('aria-valuenow', data.content4/10*100);
            }, 400);
        },

        // 차트 초기화
        initEnhancedCharts:function(){
            this.createRealtimeChart();
            this.createTopPlacesChart();
            this.createRegionPieChart();
            this.createHourlyActivityChart();
            this.updateStatCards();

            setInterval(() => {
                this.createRealtimeChart();
                this.createTopPlacesChart();
                this.createRegionPieChart();
                this.createHourlyActivityChart();
                this.updateStatCards();
            }, 10000);
        },

        createRealtimeChart:function(){
            fetch('/logs/mapclick')
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let hourlyData = {};

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let hour = parts[0].trim().substring(0, 13);
                            hourlyData[hour] = (hourlyData[hour] || 0) + 1;
                        }
                    });

                    let categories = Object.keys(hourlyData).sort().slice(-12);
                    let chartData = categories.map(h => hourlyData[h]);

                    Highcharts.chart('realtimeChart', {
                        chart: { type: 'spline' },
                        title: { text: '실시간 클릭 추이' },
                        xAxis: {
                            categories: categories.map(h => h.substring(11, 13) + '시'),
                            title: { text: '시간' }
                        },
                        yAxis: {
                            title: { text: '클릭 수' },
                            allowDecimals: false
                        },
                        series: [{
                            name: '클릭 수',
                            data: chartData,
                            color: '#4e73df'
                        }],
                        credits: { enabled: false }
                    });
                });
        },

        createTopPlacesChart:function(){
            fetch('/logs/mapclick')
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let placeCount = {};

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let place = parts[2].trim();
                            placeCount[place] = (placeCount[place] || 0) + 1;
                        }
                    });

                    let sortedPlaces = Object.entries(placeCount)
                        .sort((a, b) => b[1] - a[1])
                        .slice(0, 5);

                    let categories = sortedPlaces.map(item => item[0]);
                    let chartData = sortedPlaces.map(item => item[1]);

                    Highcharts.chart('topPlacesChart', {
                        chart: { type: 'bar' },
                        title: { text: '인기 장소 Top 5' },
                        xAxis: { categories: categories },
                        yAxis: {
                            min: 0,
                            title: { text: '방문 횟수' },
                            allowDecimals: false
                        },
                        plotOptions: {
                            bar: {
                                dataLabels: { enabled: true },
                                colorByPoint: true
                            }
                        },
                        series: [{
                            name: '방문 횟수',
                            data: chartData
                        }],
                        credits: { enabled: false }
                    });
                });
        },

        createRegionPieChart:function(){
            fetch('/logs/mapclick')
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let regionCount = {};

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let region = parts[1].trim().split(' ')[0];
                            regionCount[region] = (regionCount[region] || 0) + 1;
                        }
                    });

                    let pieData = Object.entries(regionCount).map(([name, value]) => ({
                        name: name,
                        y: value
                    }));

                    Highcharts.chart('regionDistChart', {
                        chart: { type: 'pie' },
                        title: { text: '지역별 방문 분포' },
                        tooltip: {
                            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                        },
                        plotOptions: {
                            pie: {
                                allowPointSelect: true,
                                cursor: 'pointer',
                                dataLabels: {
                                    enabled: true,
                                    format: '<b>{point.name}</b>: {point.percentage:.1f}%'
                                }
                            }
                        },
                        series: [{
                            name: '비율',
                            colorByPoint: true,
                            data: pieData
                        }],
                        credits: { enabled: false }
                    });
                });
        },

        createHourlyActivityChart:function(){
            fetch('/logs/mapclick')
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let hourCount = Array(24).fill(0);

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let hour = parseInt(parts[0].trim().split(' ')[1].split(':')[0]);
                            hourCount[hour]++;
                        }
                    });

                    Highcharts.chart('hourlyChart', {
                        chart: { type: 'column' },
                        title: { text: '시간대별 활동 분포' },
                        xAxis: {
                            categories: Array.from({length: 24}, (_, i) => i + '시'),
                            title: { text: '시간대' }
                        },
                        yAxis: {
                            min: 0,
                            title: { text: '활동 횟수' },
                            allowDecimals: false
                        },
                        series: [{
                            name: '활동 횟수',
                            data: hourCount,
                            color: '#1cc88a'
                        }],
                        credits: { enabled: false }
                    });
                });
        },

        updateStatCards:function(){
            fetch('/logs/mapclick')
                .then(response => response.text())
                .then(data => {
                    let lines = data.trim().split('\n');
                    let placeCount = {};
                    let hourCount = Array(24).fill(0);
                    let today = new Date().toISOString().split('T')[0];
                    let todayCount = 0;

                    lines.forEach(line => {
                        let parts = line.split(', ');
                        if(parts.length >= 3) {
                            let dateStr = parts[0].trim().split(' ')[0];
                            let hour = parseInt(parts[0].trim().split(' ')[1].split(':')[0]);
                            let place = parts[2].trim();

                            placeCount[place] = (placeCount[place] || 0) + 1;
                            hourCount[hour]++;

                            if(dateStr === today) todayCount++;
                        }
                    });

                    // 애니메이션과 함께 업데이트
                    const totalElement = $('#totalVisits')[0];
                    const todayElement = $('#todayVisits')[0];

                    if(totalElement) {
                        const oldTotal = parseInt($('#totalVisits').text().replace(/,/g, '')) || 0;
                        animateValue(totalElement, oldTotal, lines.length, 1000);
                    }

                    if(todayElement) {
                        const oldToday = parseInt($('#todayVisits').text().replace(/,/g, '')) || 0;
                        animateValue(todayElement, oldToday, todayCount, 1000);
                    }

                    let topPlace = Object.entries(placeCount)
                        .sort((a, b) => b[1] - a[1])[0];
                    if(topPlace) {
                        $('#topPlace').text(topPlace[0]);
                    }

                    let maxHour = hourCount.indexOf(Math.max(...hourCount));
                    $('#peakTime').text(maxHour + '시');
                });
        }
    };

    $(function(){
        center.init();
    });
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Dashboard</h1>
        <a href="/chart" class="d-none d-sm-inline-block btn btn-sm btn-primary shadow-sm"><i
                class="fas fa-chart-bar fa-sm text-white-50"></i> 상세 분석 보기</a>
    </div>
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h5 class="h5 mb-0 text-gray-800" id="aimsg"></h5>
        <img id="generatedImage" src="/img/assistant.png"
             width="100px;" class="img-fluid" alt="Generated Image" />
    </div>

    <!-- ========== 새로운 통계 카드 추가 ========== -->
    <div class="row">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-primary shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                총 방문 수</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800" id="totalVisits">-</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-users fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-success shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                오늘 방문</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800" id="todayVisits">-</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-calendar fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-info shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                1위 장소</div>
                            <div class="h6 mb-0 font-weight-bold text-gray-800" id="topPlace">-</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-trophy fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-warning shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                피크 타임</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800" id="peakTime">-</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-clock fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ========== 새로운 차트 섹션 ========== -->
    <div class="row">
        <div class="col-xl-12">
            <div class="card shadow mb-4">
                <div class="card-header card-header-gradient py-3">
                    <h6 class="m-0 font-weight-bold">📊 실시간 활동 모니터링</h6>
                </div>
                <div class="card-body">
                    <div class="enhanced-chart-container" id="realtimeChart"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-8 col-lg-7">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">🏆 인기 장소 Top 5</h6>
                </div>
                <div class="card-body">
                    <div class="enhanced-chart-container" id="topPlacesChart"></div>
                </div>
            </div>
        </div>
        <div class="col-xl-4 col-lg-5">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-success">🗺️ 지역별 분포</h6>
                </div>
                <div class="card-body">
                    <div class="enhanced-chart-container" id="regionDistChart"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-info">⏰ 시간대별 활동 패턴</h6>
                </div>
                <div class="card-body">
                    <div class="enhanced-chart-container" id="hourlyChart"></div>
                </div>
            </div>
        </div>
    </div>

</div>
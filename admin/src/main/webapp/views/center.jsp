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

    /* 페이드인 효과 */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .fade-in-card {
        animation: fadeIn 0.6s ease-out;
    }

    /* 온도 인디케이터 */
    .temperature-indicator {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: linear-gradient(135deg, #e0e0e0 0%, #f5f5f5 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        transition: all 0.5s ease;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin: 0 auto;
    }

    .temperature-indicator.heating {
        background: linear-gradient(135deg, #ff6b6b 0%, #ff8e53 100%);
        box-shadow: 0 8px 20px rgba(255, 107, 107, 0.5);
        animation: pulse-glow 2s ease-in-out infinite;
    }

    .temperature-indicator.cooling {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        box-shadow: 0 8px 20px rgba(79, 172, 254, 0.5);
        animation: pulse-glow 2s ease-in-out infinite;
    }

    @keyframes pulse-glow {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.05); }
    }

    .temp-value {
        font-size: 22px;
        font-weight: bold;
        color: #666;
    }

    .temperature-indicator.heating .temp-value,
    .temperature-indicator.cooling .temp-value {
        color: white;
    }

    .temp-label {
        font-size: 10px;
        color: #999;
        margin-top: 3px;
    }

    .temperature-indicator.heating .temp-label,
    .temperature-indicator.cooling .temp-label {
        color: rgba(255, 255, 255, 0.9);
    }

    /* 차량 인식 스타일 */
    .car-status-success {
        background-color: #d4edda;
        border: 2px solid #28a745;
        color: #155724;
    }

    .car-status-danger {
        background-color: #f8d7da;
        border: 2px solid #dc3545;
        color: #721c24;
    }

    .car-info-text {
        white-space: pre-wrap;
        font-size: 14px;
        line-height: 1.6;
        background-color: #f8f9fa;
        padding: 15px;
        border-radius: 5px;
        border-left: 4px solid #007bff;
    }
</style>

<script>
    let center = {
        adminId: null,
        targetTemperature: 22,

        init: function() {
            <c:if test="${sessionScope.admin.adminId != null}">
            this.adminId = '${sessionScope.admin.adminId}';
            this.connect();
            </c:if>

            this.initTemperatureControl();
        },

        connect: function() {
            let url = '${sseUrl}connect/' + this.adminId;
            const sse = new EventSource(url);

            sse.addEventListener('connect', (e) => {
                console.log('SSE 연결:', e.data);
            });

            sse.addEventListener('aimsg', (e) => {
                console.log('차량 인식 데이터:', e.data);
                this.handleCarRecognition(e.data);
            });
        },

        initTemperatureControl: function() {
            $('#targetTempInput').on('change', (e) => {
                this.targetTemperature = parseInt(e.target.value);
                $('#targetTempDisplay').text(this.targetTemperature + '°C');
            });
            $('#targetTempDisplay').text(this.targetTemperature + '°C');
        },

        handleCarRecognition: function(data) {
            try {
                const parsedData = JSON.parse(data);
                const result = parsedData.result;
                const base64File = parsedData.base64File;

                $('#carInfoText').html(result.trim());

                const base64Src = "data:image/png;base64," + base64File;
                $('#carImage').attr('src', base64Src);

                const isSuccess = result.includes('차단기 올림');
                const statusDiv = $('#carRecognitionStatus');

                if (isSuccess) {
                    statusDiv.removeClass('alert-danger car-status-danger')
                        .addClass('alert-success car-status-success')
                        .html('<h5>✅ 등록된 차량입니다!</h5><p class="mb-0">차단기를 올립니다. 스마트홈 시스템을 활성화합니다.</p>')
                        .fadeIn();

                    this.controlTemperature();
                } else {
                    statusDiv.removeClass('alert-success car-status-success')
                        .addClass('alert-danger car-status-danger')
                        .html('<h5>❌ 등록되지 않은 차량</h5><p class="mb-0">차단기를 내립니다.</p>')
                        .fadeIn();

                    this.resetTemperature();
                }

                const now = new Date();
                $('#lastUpdateTime').text(now.toLocaleString('ko-KR'));

            } catch(error) {
                console.error('차량 인식 오류:', error);
            }
        },

        controlTemperature: function() {
            console.log('온도 제어 시작...');

            const question = '현재 온도를 확인하고, ' + this.targetTemperature + '도로 맞춰주세요.';

            $.ajax({
                url: '/ai5/heating-system-tools',
                type: 'GET',
                data: { question: question },
                success: (response) => {
                    console.log('온도 제어 응답:', response);
                    this.updateTemperatureUI(response);
                },
                error: (error) => {
                    console.error('온도 제어 실패:', error);
                    $('#tempStatus').html('<i class="fas fa-exclamation-triangle text-warning"></i> <strong>제어 실패</strong>');
                }
            });
        },

        updateTemperatureUI: function(response) {
            const indicator = $('.temperature-indicator');
            const tempStatus = $('#tempStatus');

            if (response.includes('난방') || response.includes('가동')) {
                indicator.removeClass('cooling').addClass('heating');
                tempStatus.html('<i class="fas fa-fire text-danger"></i> <strong>난방 가동 중</strong><br><small>목표: ' + this.targetTemperature + '°C</small>');
            } else if (response.includes('중지')) {
                indicator.removeClass('heating cooling');
                tempStatus.html('<i class="fas fa-check-circle text-success"></i> <strong>목표 온도 도달</strong><br><small>' + this.targetTemperature + '°C 유지</small>');
            } else {
                indicator.removeClass('heating').addClass('cooling');
                tempStatus.html('<i class="fas fa-snowflake text-info"></i> <strong>냉방 가동 중</strong><br><small>목표: ' + this.targetTemperature + '°C</small>');
            }

            indicator.find('.temp-value').text(this.targetTemperature + '°');

            setTimeout(() => {
                indicator.removeClass('heating cooling');
                tempStatus.html('<i class="fas fa-check-circle text-success"></i> <strong>목표 온도 도달</strong><br><small>' + this.targetTemperature + '°C 유지 중</small>');
            }, 5000);
        },

        resetTemperature: function() {
            const indicator = $('.temperature-indicator');
            indicator.removeClass('heating cooling');
            indicator.find('.temp-value').text('--°');
            $('#tempStatus').html('<i class="fas fa-thermometer-half text-muted"></i> <strong>대기 중</strong><br><small>차량 인식 대기</small>');
        }
    };

    $(function() {
        center.init();
    });
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Dashboard</h1>
    </div>

    <!-- 차량 인식 실시간 모니터링 -->
    <div class="row mb-4">
        <div class="col-xl-12">
            <div class="card shadow">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <h6 class="m-0 font-weight-bold text-white">🚗 스마트 주차장 실시간 모니터링</h6>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- 차량 이미지 -->
                        <div class="col-md-5">
                            <div class="card mb-3">
                                <div class="card-header bg-info text-white">📸 최근 차량 이미지</div>
                                <div class="card-body text-center">
                                    <img id="carImage" src="/img/assistant.png" class="img-fluid rounded shadow"
                                         alt="차량 이미지" style="max-height: 300px; object-fit: contain;" />
                                </div>
                            </div>
                        </div>

                        <!-- 차량 인식 결과 -->
                        <div class="col-md-4">
                            <div class="card mb-3">
                                <div class="card-header bg-primary text-white">📋 차량 인식 결과</div>
                                <div class="card-body">
                                    <div id="carRecognitionStatus" class="alert mb-3" style="display: none;"></div>

                                    <div class="mb-3">
                                        <h6 class="font-weight-bold mb-2">상세 정보:</h6>
                                        <div id="carInfoText" class="car-info-text">대기 중...</div>
                                    </div>

                                    <div>
                                        <small class="text-muted">
                                            <i class="fas fa-clock"></i>
                                            최종 업데이트: <span id="lastUpdateTime">-</span>
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 온도 제어 패널 -->
                        <div class="col-md-3">
                            <div class="card mb-3 shadow-sm">
                                <div class="card-header text-white" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                                    🌡️ 스마트홈 온도 제어
                                </div>
                                <div class="card-body text-center">
                                    <!-- 온도 인디케이터 -->
                                    <div class="temperature-indicator mb-3">
                                        <div class="temp-value">--°</div>
                                        <div class="temp-label">목표 온도</div>
                                    </div>

                                    <!-- 목표 온도 설정 -->
                                    <div class="mb-3">
                                        <label class="font-weight-bold mb-2">목표 온도 설정</label>
                                        <div class="input-group">
                                            <input type="number" id="targetTempInput" class="form-control text-center"
                                                   value="22" min="18" max="30" step="1">
                                            <div class="input-group-append">
                                                <span class="input-group-text">°C</span>
                                            </div>
                                        </div>
                                        <small class="text-muted">권장: 20-24°C</small>
                                    </div>

                                    <!-- 상태 표시 -->
                                    <div id="tempStatus" class="mt-3 p-2 bg-light rounded">
                                        <i class="fas fa-thermometer-half text-muted"></i>
                                        <strong>대기 중</strong><br>
                                        <small>차량 인식 대기</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
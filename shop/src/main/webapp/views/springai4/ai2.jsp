<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    #travelSafetyResult {
        overflow: auto;
        width: auto;
        min-height: 400px;
        background: #f9f9f9;
        padding: 20px;
    }
    .safety-message {
        border-left: 4px solid;
        padding: 15px;
        margin: 10px 0;
        border-radius: 5px;
    }
    .level-1 { border-color: #0d6efd; background: #cfe2ff; }
    .level-2 { border-color: #ffc107; background: #fff3cd; }
    .level-3 { border-color: #dc3545; background: #f8d7da; }
    .level-4 { border-color: #000; background: #e2e3e5; }
</style>

<script>
    let travelSafetySystem = {
        init: function() {
            $('#sendTravelSafety').click(() => this.checkSafety());
            $('#questionTravelSafety').keypress((e) => {
                if (e.which === 13 && !e.shiftKey) {
                    e.preventDefault();
                    this.checkSafety();
                }
            });
            $('#spinnerTravelSafety').css('visibility', 'hidden');
        },

        checkSafety: async function() {
            const question = $('#questionTravelSafety').val().trim();

            if (!question) {
                alert('국가명을 입력해주세요.');
                return;
            }

            $('#spinnerTravelSafety').css('visibility', 'visible');

            // 사용자 메시지 표시
            let userUuid = this.makeUi("travelSafetyResult", true);
            $('#' + userUuid).text(question);
            $('#questionTravelSafety').val('');

            try {
                const response = await fetch('/ai4/travel-safety-tools', {
                    method: "post",
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams({ question })
                });

                let aiUuid = this.makeUi("travelSafetyResult");
                const answer = await response.text();

                $('#' + aiUuid).html(this.formatSafetyInfo(answer));

            } catch (error) {
                console.error('여행 안전 정보 조회 오류:', error);
                alert('안전 정보를 가져오는 중 오류가 발생했습니다.');
            } finally {
                $('#spinnerTravelSafety').css('visibility', 'hidden');
            }
        },

        makeUi: function(target, isUser = false) {
            let uuid = "id-" + crypto.randomUUID();

            if (isUser) {
                let userForm = "<div class='media border p-3 mb-2'>" +
                    "<div class='media-body'>" +
                    "<h6><i class='fas fa-user'></i> 사용자</h6>" +
                    "<p id='" + uuid + "'></p>" +
                    "</div>" +
                    "</div>";
                $('#' + target).prepend(userForm);
            } else {
                let aiForm = "<div class='media border p-3 mb-2'>" +
                    "<div class='media-body'>" +
                    "<h6><i class='fas fa-robot'></i> 여행 안전 AI</h6>" +
                    "<div id='" + uuid + "' style='white-space: pre-wrap;'></div>" +
                    "</div>" +
                    "</div>";
                $('#' + target).prepend(aiForm);
            }
            return uuid;
        },

        formatSafetyInfo: function(text) {
            let html = text;
            let isJapan = text.includes('일본') || text.includes('Japan');

            if (isJapan) {
                maxLevel = 1;
            } else {
                if (text.includes('⚫ 4단계') || text.includes('4단계 (흑색')) maxLevel = 4;
                else if (text.includes('🔴 3단계') || text.includes('3단계 (적색')) maxLevel = 3;
                else if (text.includes('🟡 2단계') || text.includes('2단계 (황색')) maxLevel = 2;
                else if (text.includes('🔵 1단계') || text.includes('1단계 (남색')) maxLevel = 1;
            }

            // 특별경보 강조
            html = html.replace(/⚠️/g, '<span style="color: red; font-size: 1.5em;">⚠️</span>');
            html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

            // 최대 레벨마다 색
            let wrapperClass = '';
            if (maxLevel === 4) {
                wrapperClass = 'safety-message level-4';
            } else if (maxLevel === 3) {
                wrapperClass = 'safety-message level-3';
            } else if (maxLevel === 2) {
                wrapperClass = 'safety-message level-2';
            } else if (maxLevel === 1) {
                wrapperClass = 'safety-message level-1';
            }

            if (wrapperClass) {
                html = '<div class="' + wrapperClass + '">' + html + '</div>';
            }

            return html;
        }
    };

    $(() => {
        travelSafetySystem.init();
    });
</script>

<div class="col-sm-10">
  <h2><i class="fas fa-globe-asia"></i> 여행 안전 정보 조회 시스템</h2>
  <p class="text-muted">외교부 API를 활용하여 실시간 여행 안전 정보를 확인하세요</p>

  <div class="section-divider">
    <div class="card">
      <div class="card-body">
        <div class="alert alert-info">
          <strong>사용 예시:</strong>
          <ul class="mb-0 mt-2">
            <li>"일본 여행 안전한가요?"</li>
            <li>"태국 안전공지 확인"</li>
            <li>"캄보디아 특별경보 있어?"</li>
          </ul>
        </div>

        <div class="row mb-3">
          <div class="col-sm-12">
            <textarea id="questionTravelSafety" class="form-control" rows="3"
                      placeholder="여행할 국가를 물어보세요..">일본 여행 안전한가요?</textarea>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-3">
            <button type="button" class="btn btn-primary w-100" id="sendTravelSafety">
              <i class="fas fa-paper-plane"></i> 조회하기
            </button>
          </div>
          <div class="col-sm-3">
            <button class="btn btn-secondary w-100" disabled>
              <span class="spinner-border spinner-border-sm" id="spinnerTravelSafety"></span>
              조회 중...
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 결과 표시 영역 -->
    <div id="travelSafetyResult" class="container p-3 my-3 border rounded">
      <div class="text-center text-muted p-5">
        <div class="row text-start mt-4">
          <div class="col-md-3">
            <div class="p-3 border rounded level-1">
              <strong>1단계 (남색)</strong><br>
              <small>여행유의</small>
            </div>
          </div>
          <div class="col-md-3">
            <div class="p-3 border rounded level-2">
              <strong>2단계 (황색)</strong><br>
              <small>여행자제</small>
            </div>
          </div>
          <div class="col-md-3">
            <div class="p-3 border rounded level-3">
              <strong>3단계 (적색)</strong><br>
              <small>출국권고</small>
            </div>
          </div>
          <div class="col-md-3">
            <div class="p-3 border rounded level-4">
              <strong>4단계 (흑색)</strong><br>
              <small>여행금지</small>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .ai-result {
        overflow: auto;
        width: auto;
        height: 400px;
        background: #f9f9f9;
    }
    .section-divider {
        margin-top: 30px;
        margin-bottom: 30px;
        border-top: 3px solid #dee2e6;
        padding-top: 30px;
    }
</style>

<script>
    let ai1 = {
        init: function() {
            $('#send1').click(() => this.uploadFile());
            $('#del1').click(() => this.clearVectors());
            $('#send2').click(() => this.sendQuestion());
            $('#question2').keypress((e) => {
                if (e.which === 13 && !e.shiftKey) {
                    e.preventDefault();
                    this.sendQuestion();
                }
            });
            $('.spinner').css('visibility', 'hidden');
        },

        makeUi: function(target, isUser = false) {
            let uuid = "id-" + crypto.randomUUID();
            let template = "<div class='media border p-3'>" +
                "<div class='media-body'>" +
                "<h6>" + (isUser ? 'User' : 'AI Assistant') + "</h6>" +
                "<p><pre id='" + uuid + "' style='white-space: pre-wrap;'></pre></p>" +
                "</div>" +
                "</div>";
            $('#' + target).prepend(template);
            return uuid;
        },

        showSpinner: function(id, show) {
            $('#spinner' + id).css('visibility', show ? 'visible' : 'hidden');
        },

        // 파일 업로드
        uploadFile: async function() {
            const type = $('#type1').val();
            const attach = document.getElementById("attach1").files[0];

            if (!type) {
                alert("구분을 입력해야 합니다.");
                return;
            }
            if (!attach) {
                alert("문서 파일을 선택해야 합니다.");
                return;
            }

            this.showSpinner(1, true);

            const formData = new FormData();
            formData.append("type", type);
            formData.append("attach", attach);

            try {
                const response = await fetch('/ai4/txt-pdf-docx-etl', {
                    method: "post",
                    body: formData
                });

                let uuid = this.makeUi("result1");
                const reader = response.body.getReader();
                const decoder = new TextDecoder("utf-8");
                let content = "";

                while (true) {
                    const {value, done} = await reader.read();
                    if (done) break;
                    content += decoder.decode(value);
                    $('#' + uuid).html(content);
                }

                $('#' + uuid).append('업로드가 완료되었습니다!');
            } catch (error) {
                console.error('ETL 오류:', error);
                alert('문서 처리 중 오류가 발생했습니다.');
            } finally {
                this.showSpinner(1, false);
            }
        },

        // 벡터 데이터 삭제
        clearVectors: function() {
            if (!confirm('저장된 벡터 데이터를 모두 삭제하시겠습니까?')) return;

            $.ajax({
                url: '/ai4/rag-clear',
                method: 'POST',
                success: function() {
                    alert('삭제되었습니다.');
                    $('#result1').html('<div class="alert alert-info">벡터 데이터가 삭제되었습니다.</div>');
                },
                error: function() {
                    alert('삭제 중 오류가 발생했습니다.');
                }
            });
        },

        // AI 질문 전송
        sendQuestion: async function() {
            const question = $('#question2').val().trim();

            if (!question) {
                alert('질문을 입력해주세요.');
                return;
            }

            this.showSpinner(2, true);

            let userUuid = this.makeUi("result2", true);
            $('#' + userUuid).text(question);
            $('#question2').val('');

            try {
                const response = await fetch('/ai4/chat-with-tools', {
                    method: "post",
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams({ question })
                });

                let aiUuid = this.makeUi("result2");
                const answer = await response.text();
                $('#' + aiUuid).text(answer);
            } catch (error) {
                console.error('AI 응답 오류:', error);
                alert('응답 중 오류가 발생했습니다.');
            } finally {
                this.showSpinner(2, false);
            }
        }
    };

    $(() => ai1.init());
</script>

<div class="col-sm-10">
  <h2><i class="fas fa-robot"></i> AI 통합 시스템</h2>
  <p class="text-muted">문서 업로드 및 날씨/추천 기능을 사용할 수 있습니다.</p>

  <!-- 파일 업로드 -->
  <div class="section-divider">
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0"><i class="fas fa-file-upload"></i> 문서 업로드 및 ETL</h5>
      </div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-sm-12">
            <label class="form-label">구분</label>
            <input id="type1" class="form-control" type="text" placeholder="예: jeju, busan"/>
            <small class="text-muted">문서를 구분할 카테고리를 입력하세요</small>
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-sm-12">
            <label class="form-label">문서 파일</label>
            <input id="attach1" class="form-control" type="file" accept=".txt,.pdf,.docx"/>
            <small class="text-muted">TXT, PDF, DOCX 파일 지원</small>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-3">
            <button type="button" class="btn btn-primary w-100" id="send1">
              <i class="fas fa-upload"></i> 업로드 및 처리
            </button>
          </div>
          <div class="col-sm-3">
            <button type="button" class="btn btn-danger w-100" id="del1">
              <i class="fas fa-trash"></i> 벡터 데이터 삭제
            </button>
          </div>
          <div class="col-sm-3">
            <button class="btn btn-secondary w-100" disabled>
              <span class="spinner-border spinner-border-sm spinner" id="spinner1"></span>
              처리 중...
            </button>
          </div>
        </div>
      </div>
    </div>

    <div id="result1" class="container p-3 my-3 border rounded ai-result">
      <div class="text-center text-muted p-5">
        <i class="fas fa-cloud-upload-alt fa-3x mb-3"></i>
        <p>문서를 업로드하면 ETL 처리 결과가 여기에 표시됩니다</p>
      </div>
    </div>
  </div>

  <!-- 날씨/추천 도구 -->
  <div class="section-divider">
    <h3><i class="fas fa-magic"></i>날씨 정보 및 맛집 추천 AI</h3>
    <div class="card">
      <div class="card-body">
        <div class="alert alert-info">
          <strong>예시:</strong>
          <ul class="mb-0 mt-2">
            <li>"일본 날씨 알려줘"</li>
            <li>"제주도 맛집 5곳 추천해줘"</li>
            <li>"부산 국밥집 3곳 추천해줘"</li>
          </ul>
          <small class="text-muted">※ 관광지/맛집 추천은 먼저 위의 "파일 업로드"에서 관련 문서를 업로드해야 합니다.</small>
        </div>

        <div class="row mb-3">
          <div class="col-sm-12">
            <label class="form-label">질문</label>
            <textarea id="question2" class="form-control" rows="3"
                      placeholder="날씨 정보나 여행지 추천을 요청하세요... (Enter로 전송, Shift+Enter로 줄바꿈)">일본 날씨 알려줘</textarea>
          </div>
        </div>

        <div class="row">
          <div class="col-sm-3">
            <button type="button" class="btn btn-warning w-100" id="send2">
              <i class="fas fa-paper-plane"></i> 전송
            </button>
          </div>
          <div class="col-sm-3">
            <button class="btn btn-secondary w-100" disabled>
              <span class="spinner-border spinner-border-sm spinner" id="spinner2"></span>
              처리 중...
            </button>
          </div>
        </div>
      </div>
    </div>

    <div id="result2" class="container p-3 my-3 border rounded ai-result">
      <div class="text-center text-muted p-5">
        <i class="fas fa-tools fa-3x mb-3"></i>
        <p>날씨 조회, 맛집 추천 등 다양한 AI 도구를 사용해보세요</p>
      </div>
    </div>
  </div>

</div>

<%--
  Created by IntelliJ IDEA.
  User: 건
  Date: 2025-10-20
  Time: 오후 4:59:03
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 채팅 로그 스타일 */
    #chat-log {
        height: 300px; /* 채팅 로그 높이 */
        overflow-y: auto;
        display: flex;
        flex-direction: column-reverse; /* 새 채팅이 항상 상단에 오도록 */
        border: 1px solid #ddd;
        border-radius: 5px;
        padding: 10px;
        margin-bottom: 20px;
        background: #f9f9f9;
    }
    /* 캘린더 높이 확보 */
    #calendar {
        height: 700px;
    }
</style>

<script>
    let ai4 = {
        calendar: null, // FullCalendar 인스턴스를 저장할 변수

        init: function () {
            this.initCalendar(); // 캘린더 초기화
            this.startQuestion(); // 음성 입력 대기 시작

            $('#send').click(() => {
                this.send();
            });
            $('#spinner').css('visibility', 'hidden');
        },

        // FullCalendar 초기화 함수
        initCalendar: function() {
            let calendarEl = document.getElementById('calendar');
            this.calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth', // 월간 뷰
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,listWeek'
                },
                editable: true, // 이벤트 드래그 수정
                events: [
                    // 테스트용 예시 이벤트
                    {
                        title: '[식비] 12,000원',
                        start: new Date(),
                        allDay: true,
                        color: '#e57373'
                    }
                ],
                // 날짜 클릭 시
                dateClick: function(info) {
                    $('#question').val(info.dateStr + ' ');
                    $('#question').focus();
                }
            });
            this.calendar.render();
        },

        startQuestion: function () {
            springai.voice.initMic(this);
            let qForm = `
            <div class="media border p-3 my-2" id="voice-prompt">
               <div class="speakerPulse"
                  style="width: 30px; height: 30px;
                  background: url('/image/speaker-yellow.png') no-repeat center center / contain;"></div>
              <div class="media-body">
                <p class="text-muted" style="margin-left: 10px; padding-top: 5px;">
                  음성으로 가계부 내역을 말씀하세요... (예: 어제 스타벅스 7천원 지출)
                </p>
              </div>
            </div>
            `;
            $('#chat-log').prepend(qForm);
        },

        // 2. 음성 녹음 완료 시 (STT)
        handleVoice: async function (mp3Blob) {
            $('#spinner').css('visibility', 'visible');
            $('#voice-prompt').remove();

            const formData = new FormData();
            formData.append("speech", mp3Blob, 'speech.mp3');

            const response = await fetch("/ai3/stt", {
                method: "post",
                headers: { 'Accept': 'text/plain' },
                body: formData
            });

            const questionText = await response.text();
            console.log('STT Result:' + questionText);

            // 사용자 질문을 채팅 패널에 보여주기
            this.showUserChat(questionText);

            // AI에게 텍스트 전달
            await this.processInput(questionText);
        },

        send: async function () {
            let question = $('#question').val().trim();
            if (!question) {
                alert('내용을 입력하세요.');
                return;
            }

            $('#voice-prompt').remove();
            this.showUserChat(question);
            await this.processInput(question);
        },

        // 4. AI에게 가계부 내역 추출 요청
        processInput: async function (questionText) {
            $('#spinner').css('visibility', 'visible');
            $('#question').val('');

            let confirmationMsg = ''; // AI가 응답할 최종 메시지

            try {
                const response = await fetch('/ai3/accountbook', {
                    method: 'post',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json' // [중요] JSON을 반환받음
                    },
                    body: new URLSearchParams({ question: questionText })
                });

                if (!response.ok) {
                    throw new Error('AI 서버 응답 오류');
                }

                // AI가 추출한 JSON 데이터
                // 예: { "date": "2025-10-20", "category": "식비", "amount": 8000, "type": "expense", "memo": "점심값" }
                const data = await response.json();

                if (!data || !data.date || !data.amount) {
                    throw new Error('AI가 날짜와 금액을 추출하지 못했습니다.');
                }

                this.addEventToCalendar(data);

                const typeStr = data.type === 'expense' ? '지출' : '수입';
                confirmationMsg = data.date + "에 " + data.category + " 항목으로 " + data.amount + "원 " + typeStr + " 내역을 등록했습니다.";

            } catch (error) {
                console.error('Error processing input:', error);
                confirmationMsg = '오류가 발생했습니다: ' + error.message + ' (예: 오늘 식비 5천원 지출)';
            } finally {
                await this.speak(confirmationMsg);
            }
        },

        // 5. FullCalendar에 이벤트 추가
        addEventToCalendar: function(data) {
            const isExpense = data.type === 'expense';
            let newEvent = {
                title: '[' + data.category + '] ' + data.memo + data.amount + '원',
                start: data.date, // AI가 추출한 날짜
                allDay: true,
                color: isExpense ? '#e57373' : '#81c784',
                extendedProps: { // 추가 데이터
                    amount: data.amount,
                    memo: data.memo || data.category
                }
            };
            this.calendar.addEvent(newEvent);
            this.calendar.gotoDate(data.date); // 해당 날짜로 캘린더 이동
        },

        // 7. AI가 음성(TTS)으로 응답
        speak: async function(text) {
            this.showAiChat(text);

            try {
                const ttsResponse = await fetch('/ai3/tts', {
                    method: "post",
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams({ text: text })
                });

                if (!ttsResponse.ok) {
                    const errorText = await ttsResponse.text();
                    throw new Error(`TTS 서버 응답 오류 (${ttsResponse.status}): ${errorText}`);
                }

                const audioBlob = await ttsResponse.blob();
                const audioUrl = URL.createObjectURL(audioBlob);
                const audioPlayer = document.getElementById("audioPlayer");

                if (audioPlayer.dataset.currentUrl) {
                    URL.revokeObjectURL(audioPlayer.dataset.currentUrl);
                }

                audioPlayer.src = audioUrl;
                audioPlayer.dataset.currentUrl = audioUrl;

                audioPlayer.addEventListener("ended", () => {
                    $('#spinner').css('visibility', 'hidden');
                    this.startQuestion();
                }, { once: true });

                audioPlayer.onerror = (e) => {
                    console.error("Audio playback error:", e);
                    $('#spinner').css('visibility', 'hidden');
                    this.startQuestion();
                    if (audioPlayer.dataset.currentUrl) {
                        URL.revokeObjectURL(audioPlayer.dataset.currentUrl);
                        delete audioPlayer.dataset.currentUrl;
                    }
                };

                try {
                    await audioPlayer.play();
                } catch (playError) {
                    console.error("Error attempting to play audio:", playError);
                    $('#spinner').css('visibility', 'hidden');
                    this.startQuestion();
                    if (audioPlayer.dataset.currentUrl) {
                        URL.revokeObjectURL(audioPlayer.dataset.currentUrl);
                        delete audioPlayer.dataset.currentUrl;
                    }
                }

            } catch (error) {
                console.error("TTS Fetch Error:", error);
                $('#spinner').css('visibility', 'hidden');
                this.startQuestion();
            }
        },
        // --- UI 헬퍼 함수 ---
        showUserChat: function(text) {
            let qForm =
                '<div class="media border p-3 my-2 bg-light">' +
                '<div class="media-body text-right">' +
                '<h6>USER</h6>' +
                '<p>' + text + '</p>' +
                '</div>' +
                '</div>';
            $('#chat-log').prepend(qForm);
        },
        showAiChat: function(text) {
            let aForm =
                '<div class="media border p-3 my-2 bg-light">' +
                '<div class="media-body text-right">' +
                '<h6>AI Assistant</h6>' +
                '<p>' + text + '</p>' +
                '</div>' +
                '<img src="/image/assistant.png" alt="AI" class="ml-3 mt-3 rounded-circle" style="width:60px;">' +
                '</div>';
            $('#chat-log').prepend(aForm);
        }
    };

    $(() => {
        ai4.init();
    });

</script>

<div class="col-sm-10">
  <h2>가계부 AI</h2>
  <p class="text-muted">음성이나 텍스트로 지출/수입 내역을 말하면 AI가 캘린더에 등록합니다.</p>
  <audio id="audioPlayer" controls style="display:none;"></audio>

  <div class="row mb-3">
    <div class="col-sm-8">
      <textarea id="question" class="form-control" placeholder="예: 오늘 택시비 15000원 지출"></textarea>
    </div>
    <div class="col-sm-2">
      <button type="button" class="btn btn-primary btn-block" id="send">전송</button>
    </div>
    <div class="col-sm-2">
      <button class="btn btn-primary btn-block" disabled>
        <span class="spinner-border spinner-border-sm" id="spinner"></span>
        Processing..
      </button>
    </div>
  </div>

  <div id="chat-log">
  </div>

  <div id="calendar" class="p-3 my-3 border rounded">
  </div>

</div>

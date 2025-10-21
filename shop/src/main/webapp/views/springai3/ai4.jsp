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
        height: 300px;
        overflow-y: auto;
        display: flex;
        flex-direction: column-reverse;
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
    /* 필터/검색 패널 스타일 */
    .filter-panel {
        background: #f8f9fa;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
        border: 1px solid #dee2e6;
    }
    .filter-panel label {
        font-weight: 600;
        margin-bottom: 5px;
        display: block;
    }
    /* 통계 카드 */
    .stats-card {
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 10px;
        text-align: center;
        color: white;
    }
    .stats-card h4 {
        margin: 0;
        font-size: 24px;
    }
    .stats-card p {
        margin: 5px 0 0 0;
        font-size: 12px;
    }
    /* all-day 텍스트 숨기기 */
    .fc-list-item-time {
        display: none !important;
    }
</style>

<script>
    let ai4 = {
        calendar: null,
        allEvents: [],
        categories: ['식비', '고정비', '교통/차량비', '생활/쇼핑', '여가/문화/교육', '기타 지출', '수입'],
        currentEditEvent: null, // 현재 수정 중인 이벤트

        init: function () {
            this.initCalendar();
            this.initFilters();
            this.initModal();
            this.startQuestion();

            $('#send').click(() => {
                this.send();
            });
            $('#question').keypress((e) => {
                if (e.which === 13 && !e.shiftKey) {
                    e.preventDefault();
                    $('#send').click();
                }
            });

            $('#spinner').css('visibility', 'hidden');
        },

        // 모달 초기화
        initModal: function() {
            // 저장 버튼
            $('#saveEdit').click(() => {
                this.saveEventEdit();
            });

            // 삭제 버튼
            $('#deleteEvent').click(() => {
                this.deleteEvent();
            });
        },

        // FullCalendar 초기화
        initCalendar: function() {
            let calendarEl = document.getElementById('calendar');
            this.calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                locale: 'ko',
                displayEventTime: false,
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,listMonth'
                },
                editable: true,
                events: [],
                dateClick: (info) => {
                    $('#question').val(info.dateStr + ' ');
                    $('#question').focus();
                },
                eventClick: (info) => {
                    this.openEditModal(info.event);
                }
            });
            this.calendar.render();
        },

        // 수정 모달 열기
        openEditModal: function(event) {
            this.currentEditEvent = event;

            // 모달에 데이터 채우기
            $('#editDate').val(event.startStr);
            $('#editCategory').val(event.extendedProps.category);
            $('#editAmount').val(event.extendedProps.amount);
            $('#editMemo').val(event.extendedProps.memo);
            $('#editType').val(event.extendedProps.type);

            // 모달 열기
            $('#editModal').modal('show');
        },

        // 이벤트 수정 저장
        saveEventEdit: function() {
            if (!this.currentEditEvent) return;

            let newDate = $('#editDate').val();
            let newCategory = $('#editCategory').val();
            let newAmount = parseFloat($('#editAmount').val());
            let newMemo = $('#editMemo').val();
            let newType = $('#editType').val();

            if (!newDate || !newAmount || !newMemo) {
                alert('모든 필드를 입력해주세요.');
                return;
            }

            // 이벤트 업데이트
            this.currentEditEvent.setProp('title', '[' + newCategory + '] ' + newAmount.toLocaleString() + '원 ' + newMemo);
            this.currentEditEvent.setStart(newDate);
            this.currentEditEvent.setEnd(null);
            this.currentEditEvent.setExtendedProp('category', newCategory);
            this.currentEditEvent.setExtendedProp('amount', newAmount);
            this.currentEditEvent.setExtendedProp('memo', newMemo);
            this.currentEditEvent.setExtendedProp('type', newType);

            // 색상 변경
            let isExpense = newType === 'expense';
            this.currentEditEvent.setProp('color', isExpense ? '#e57373' : '#81c784');

            // allEvents 배열도 업데이트
            let eventIndex = this.allEvents.findIndex(e => e.id === this.currentEditEvent.id);
            if (eventIndex !== -1) {
                this.allEvents[eventIndex].title = '[' + newCategory + '] ' + newAmount.toLocaleString() + '원 ' + newMemo;
                this.allEvents[eventIndex].start = newDate;
                this.allEvents[eventIndex].allDay = true;
                delete this.allEvents[eventIndex].end;
                this.allEvents[eventIndex].extendedProps.category = newCategory;
                this.allEvents[eventIndex].extendedProps.amount = newAmount;
                this.allEvents[eventIndex].extendedProps.memo = newMemo;
                this.allEvents[eventIndex].extendedProps.type = newType;
                this.allEvents[eventIndex].color = isExpense ? '#e57373' : '#81c784';
            }

            this.updateStats();
            $('#editModal').modal('hide');
            this.currentEditEvent = null;
        },

        // 이벤트 삭제
        deleteEvent: function() {
            if (!this.currentEditEvent) return;

            if (confirm('정말 삭제하시겠습니까?')) {
                this.currentEditEvent.remove();
                this.removeFromAllEvents(this.currentEditEvent.id);
                this.updateStats();
                $('#editModal').modal('hide');
                this.currentEditEvent = null;
            }
        },

        // 필터 및 검색 초기화
        initFilters: function() {
            $('#categoryFilter').on('change', () => {
                this.applyFilters();
            });

            $('#searchInput').on('input', () => {
                this.applyFilters();
            });

            $('#searchBtn').click(() => {
                this.applyFilters();
            });

            $('#resetBtn').click(() => {
                $('#categoryFilter').val('all');
                $('#searchInput').val('');
                this.applyFilters();
            });
        },

        applyFilters: function() {
            let category = $('#categoryFilter').val();
            let searchTerm = $('#searchInput').val().toLowerCase().trim();

            this.calendar.removeAllEvents();

            let filteredEvents = this.allEvents.filter(event => {
                let matchCategory = category === 'all' || event.extendedProps.category === category;
                let matchSearch = !searchTerm ||
                    event.title.toLowerCase().includes(searchTerm) ||
                    (event.extendedProps.memo && event.extendedProps.memo.toLowerCase().includes(searchTerm));

                return matchCategory && matchSearch;
            });

            filteredEvents.forEach(event => {
                this.calendar.addEvent(event);
            });

            this.updateStats();
        },

        startQuestion: function () {
            springai.voice.initMic(this);
            let qForm = `
            <div class="media border p-3 my-2" id="voice-prompt">
               <div class="speakerPulse"
                  style="width: 30px; height: 30px; no-repeat center center / contain;"></div>
              <div class="media-body">
                <p class="text-muted" style="margin-left: 10px; padding-top: 5px;">
                  음성으로 가계부 내역을 말씀하세요... (예: 어제 스타벅스 7천원 지출)
                </p>
              </div>
            </div>
            `;
            $('#chat-log').prepend(qForm);
        },

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

            this.showUserChat(questionText);
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

        processInput: async function (questionText) {
            $('#spinner').css('visibility', 'visible');
            $('#question').val('');

            let confirmationMsg = '';

            try {
                const response = await fetch('/ai3/accountbook', {
                    method: 'post',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: new URLSearchParams({ question: questionText })
                });

                if (!response.ok) {
                    throw new Error('AI 서버 응답 오류');
                }

                const data = await response.json();

                let transactions = Array.isArray(data) ? data : [data];

                let validTransactions = transactions.filter(function(item) {
                    return item && item.date && item.amount;
                });

                if (validTransactions.length === 0) {
                    throw new Error('AI가 날짜와 금액을 추출하지 못했습니다.');
                }

                let summaries = [];
                for (let i = 0; i < validTransactions.length; i++) {
                    let transaction = validTransactions[i];
                    this.addEventToCalendar(transaction);
                    let typeStr = transaction.type === 'expense' ? '지출' : '수입';
                    summaries.push(transaction.category + ' ' + transaction.amount.toLocaleString() + '원 ' + typeStr);
                }

                if (validTransactions.length === 1) {
                    let t = validTransactions[0];
                    let typeStr = t.type === 'expense' ? '지출' : '수입';
                    confirmationMsg = t.date + '에 ' + t.category + ' 항목으로 ' + t.amount.toLocaleString() + '원 ' + typeStr + ' 내역을 등록했습니다.';
                } else {
                    confirmationMsg = '총 ' + validTransactions.length + '건의 내역을 등록했습니다. ' + summaries.join(', ');
                }

            } catch (error) {
                console.error('Error processing input:', error);
                confirmationMsg = '오류가 발생했습니다: ' + error.message + ' (예: 오늘 식비 5천원 지출)';
            } finally {
                await this.speak(confirmationMsg);
            }
        },

        addEventToCalendar: function(data) {
            const isExpense = data.type === 'expense';
            const eventId = 'event-' + Date.now() + '-' + Math.random();

            let newEvent = {
                id: eventId,
                title: '[' + data.category + '] ' + data.amount.toLocaleString() + '원 ' + data.memo,
                start: data.date,
                allDay: true,
                color: isExpense ? '#e57373' : '#81c784',
                extendedProps: {
                    amount: data.amount,
                    memo: data.memo || data.category,
                    type: data.type,
                    category: data.category
                }
            };

            this.allEvents.push(newEvent);

            let currentCategory = $('#categoryFilter').val();
            if (currentCategory === 'all' || currentCategory === data.category) {
                this.calendar.addEvent(newEvent);
            }

            this.calendar.gotoDate(data.date);
            this.updateStats();
        },

        removeFromAllEvents: function(eventId) {
            this.allEvents = this.allEvents.filter(e => e.id !== eventId);
        },

        updateStats: function() {
            let totalIncome = 0;
            let totalExpense = 0;
            let currentEvents = this.calendar.getEvents();

            currentEvents.forEach(event => {
                let amount = event.extendedProps.amount;
                if (event.extendedProps.type === 'expense') {
                    totalExpense += amount;
                } else {
                    totalIncome += amount;
                }
            });

            $('#totalIncome').text(totalIncome.toLocaleString() + '원');
            $('#totalExpense').text(totalExpense.toLocaleString() + '원');
        },

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
                    throw new Error('TTS 서버 응답 오류');
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
                '</div>';
            $('#chat-log').prepend(aForm);
        }
    };

    $(() => {
        ai4.init();
    });

</script>

<div class="col-sm-10">
  <h2>AI 가계부</h2>
  <p class="text-muted">음성이나 텍스트로 지출/수입 내역을 말하면 AI가 캘린더에 등록합니다.</p>
  <audio id="audioPlayer" controls style="display:none;"></audio>

  <!-- 통계 카드 -->
  <div class="row mb-3">
    <div class="col-sm-5">
      <div class="stats-card" style="background: green">
        <h4 id="totalIncome">0원</h4>
        <p>총 수입</p>
      </div>
    </div>
    <div class="col-sm-5">
      <div class="stats-card" style="background: red">
        <h4 id="totalExpense">0원</h4>
        <p>총 지출</p>
      </div>
    </div>
  </div>

  <!-- 입력 영역 -->
  <div class="row mb-3">
    <div class="col-sm-8">
      <textarea id="question" class="form-control" placeholder="예: 오늘 택시비 15000원 지출" rows="2"></textarea>
    </div>
    <div class="col-sm-2">
      <button type="button" class="btn btn-primary btn-block" id="send" style="height: 100%;">
        전송
      </button>
    </div>
    <div class="col-sm-2">
      <button class="btn btn-secondary btn-block" disabled style="height: 100%;">
        <span class="spinner-border spinner-border-sm" id="spinner"></span>
        처리중..
      </button>
    </div>
  </div>

  <!-- 채팅 로그 -->
  <div id="chat-log"></div>

  <!-- 필터 및 검색 패널 -->
  <div class="filter-panel">
    <div class="row">
      <div class="col-sm-4">
        <label for="categoryFilter">카테고리 필터</label>
        <select id="categoryFilter" class="form-control">
          <option value="all">전체 보기</option>
          <option value="식비">식비</option>
          <option value="고정비">고정비</option>
          <option value="교통/차량비">교통/차량비</option>
          <option value="생활/쇼핑">생활/쇼핑</option>
          <option value="여가/문화/교육">여가/문화/교육</option>
          <option value="기타 지출">기타 지출</option>
          <option value="수입">수입</option>
        </select>
      </div>
      <div class="col-sm-6">
        <label for="searchInput">내역 검색</label>
        <input type="text" id="searchInput" class="form-control" placeholder="검색어를 입력하세요 (예: 스타벅스, 택시)">
      </div>
      <div class="col-sm-2">
        <button type="button" class="btn btn-info btn-block" id="searchBtn">검색</button>
        <button type="button" class="btn btn-secondary btn-block mt-1" id="resetBtn">초기화</button>
      </div>
    </div>
  </div>

  <!-- 캘린더 -->
  <div id="calendar" class="p-3 my-3 border rounded"></div>

</div>

<!-- 수정 모달 -->
<div class="modal fade" id="editModal" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">가계부 내역 수정</h5>
        <button type="button" class="close" data-dismiss="modal">
        </button>
      </div>
      <div class="modal-body">
        <div class="form-group">
          <label for="editDate">날짜</label>
          <input type="date" class="form-control" id="editDate">
        </div>
        <div class="form-group">
          <label for="editCategory">카테고리</label>
          <select class="form-control" id="editCategory">
            <option value="식비">식비</option>
            <option value="고정비">고정비</option>
            <option value="교통/차량비">교통/차량비</option>
            <option value="생활/쇼핑">생활/쇼핑</option>
            <option value="여가/문화/교육">여가/문화/교육</option>
            <option value="기타 지출">기타 지출</option>
            <option value="수입">수입</option>
          </select>
        </div>
        <div class="form-group">
          <label for="editAmount">금액</label>
          <input type="number" class="form-control" id="editAmount">
        </div>
        <div class="form-group">
          <label for="editMemo">메모</label>
          <input type="text" class="form-control" id="editMemo">
        </div>
        <div class="form-group">
          <label for="editType">유형</label>
          <select class="form-control" id="editType">
            <option value="expense">지출</option>
            <option value="income">수입</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-danger" id="deleteEvent">삭제</button>
        <button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
        <button type="button" class="btn btn-primary" id="saveEdit">저장</button>
      </div>
    </div>
  </div>
</div>

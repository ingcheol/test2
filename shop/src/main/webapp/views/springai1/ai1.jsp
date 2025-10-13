<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css' rel='stylesheet' />
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'></script>

<style>
  .container{max-width:1200px;margin:20px auto;padding:0 15px}
  .header{border-bottom:2px solid #333;padding-bottom:15px;margin-bottom:30px}
  .header h2{font-size:28px;font-weight:bold;margin:0 0 10px 0}
  .header p{color:#666;margin:0}
  .search-box{background:#f5f5f5;border:1px solid #ddd;padding:20px;margin-bottom:30px}
  .search-box label{font-weight:bold;display:block;margin-bottom:10px}
  .search-box textarea{width:100%;padding:10px;border:1px solid #ccc;font-size:14px}
  .search-box button{padding:10px 20px;margin:15px 10px 0 0;border:1px solid #333;background:#fff;cursor:pointer}
  .search-box button:hover{background:#333;color:#fff}
  .examples{margin-top:15px;padding-top:15px;border-top:1px solid #ddd}
  .examples a{color:#06c;margin-right:15px;cursor:pointer}
  #calendar{border:1px solid #ddd;padding:15px;margin-bottom:30px;background:#fff}
  .schedule,.schedule-title,.day,.place{border:1px solid #ddd}
  .schedule{background:#fff}
  .schedule-title{background:#333;color:#fff;padding:15px 20px;font-size:20px;font-weight:bold;border:none}
  .day{border-bottom:1px solid #ddd;padding:20px;border-left:none;border-right:none;border-top:none}
  .day:last-child{border:none}
  .day-title{font-size:18px;font-weight:bold;margin-bottom:15px;padding-bottom:10px;border-bottom:2px solid #eee}
  .place{padding:15px 0;border-bottom:1px dotted #ddd;border-left:none;border-right:none;border-top:none}
  .place:last-child{border:none}
  .place .time{font-weight:bold;color:#d9534f;margin-bottom:5px}
  .place .name{font-size:16px;font-weight:bold;margin-bottom:8px}
  .place .desc{color:#555;line-height:1.6;margin-bottom:8px}
  .place .tip{background:#fffbea;border-left:3px solid #f0ad4e;padding:10px;margin-top:8px;font-size:13px}
  .loading,.error{border:1px solid #ddd;padding:30px;margin-bottom:30px}
  .loading{background:#f5f5f5;text-align:center;display:none}
  .error{background:#f8d7da;border-color:#f5c6cb}
</style>

<script>
  let calendar;

  ai1 = {
    init:function(){
      $('#send').click(()=>this.send());
      $('.ex').click(function(){ $('#question').val($(this).text()); });

      calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
        initialView: 'dayGridMonth',
        headerToolbar: false,
        locale: 'ko',
        height: 'auto'
      });
      calendar.render();
    },

    send:function(){
      const q = $('#question').val().trim();
      if(!q) { alert('질문을 입력해주세요.'); return; }

      $('.loading').show();
      $('#result').empty();

      $.ajax({
        url:'<c:url value="/ai1/few-shot-prompt"/>',
        data:{question:q},
        success:(r)=>this.display(r),
        error:()=>{ $('.loading').hide(); $('#result').html('<div class="error">오류: 일정을 불러오는데 실패했습니다.</div>'); }
      });
    },

    display:function(result){
      $('.loading').hide();
      try {
        let json = result.trim().replace(/```json\n?/g, '').replace(/```\n?/g, '');
        const start = json.indexOf('{'), end = json.lastIndexOf('}');
        if(start !== -1 && end > start) json = json.substring(start, end + 1);

        const data = JSON.parse(json);
        if(!data.schedule || !Array.isArray(data.schedule)) throw new Error('일정 없음');

        this.render(data);
        this.updateCal(data);
      } catch(e) {
        $('#result').html('<div class="error">오류: 일정 데이터를 처리할 수 없습니다.</div>');
      }
    },

    render:function(d){
      let h = '<div class="schedule"><div class="schedule-title">' + (d.title || '여행 일정') + '</div>';

      d.schedule.forEach((day, i) => {
        h += '<div class="day"><div class="day-title">' + (day.date || (i+1)+'일차') + '</div>';
        if(day.places && day.places.length) {
          day.places.forEach(p => {
            h += '<div class="place">';
            h += '<div class="time">' + (p.time || '시간 미정') + '</div>';
            h += '<div class="name">' + (p.name || '장소명 없음') + '</div>';
            if(p.description) h += '<div class="desc">' + p.description + '</div>';
            if(p.tip) h += '<div class="tip">TIP: ' + p.tip + '</div>';
            h += '</div>';
          });
        }
        h += '</div>';
      });

      $('#result').html(h + '</div>');
    },

    updateCal:function(d){
      calendar.removeAllEvents();
      const today = new Date(), events = [], colors = ['#5b9bd5'];

      d.schedule.forEach((day, di) => {
        const date = new Date(today);
        date.setDate(today.getDate() + di);
        if(day.places) {
          day.places.forEach((p, pi) => {
            events.push({
              title: p.name || '장소',
              start: date,
              backgroundColor: colors[pi % colors.length],
              extendedProps: { time: p.time || '시간 미정', desc: p.description || '', tip: p.tip || '' }
            });
          });
        }
      });

      if(events.length) {
        calendar.addEventSource(events);
        calendar.gotoDate(today);
        calendar.off('eventClick');
        calendar.on('eventClick', (i) => {
          const e = i.event;
          alert(e.title + '\n\n시간: ' + e.extendedProps.time + '\n\n' + e.extendedProps.desc +
                  (e.extendedProps.tip ? '\n\nTIP: ' + e.extendedProps.tip : ''));
        });
      }
    }
  }

  $(()=>ai1.init());
</script>

<div class="container">
  <div class="header">
    <h2>여행 일정 만들기</h2>
    <p>천안, 제주도 등 원하는 지역의 여행 일정을 만들어드립니다.</p>
  </div>

  <div class="search-box">
    <label>질문 입력</label>
    <textarea id="question" rows="3" placeholder="예) 천안 당일치기 코스 추천해줘">천안 당일치기 코스 추천해줘</textarea>
    <div>
      <button id="send">검색</button>
      <button onclick="$('#question').val('');">초기화</button>
    </div>
    <div class="examples">
      <span><b>예시:</b></span>
      <a class="ex">천안 당일치기 코스 추천해줘</a>
      <a class="ex">천안 1박2일 가족여행</a>
      <a class="ex">제주도 2박3일 여행</a>
      <a class="ex">제주도 당일치기 동부</a>
    </div>
  </div>

    <div class="loading"><strong>일정을 만들고 있습니다...</strong></div>
    <div id="calendar"></div>
    <div id="result"></div>
</div>
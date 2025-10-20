<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .translation-result {
        background: mediumpurple;
        border-radius: 15px;
        padding: 20px;
        margin-bottom: 20px;
        color: white;
    }

    .text-box {
        background: rgba(255, 255, 255, 0.2);
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 15px;
        word-wrap: break-word;
        word-break: break-word;
    }

    .language-badge {
        display: inline-block;
        padding: 5px 15px;
        border-radius: 20px;
        background: rgba(255, 255, 255, 0.3);
        margin-bottom: 10px;
        font-size: 0.9em;
    }

</style>

<script>
    let translator = {
        targetLanguage: 'en', // 기본 번역 대상 언어

        init:function(){
            this.startListening();
            $('#spinner').css('visibility','hidden');

            // 언어 선택 버튼 이벤트
            $('.lang-btn').click((e) => {
                const selectedLang = $(e.currentTarget).data('lang');
                this.selectTargetLanguage(selectedLang);
            });
        },

        selectTargetLanguage: function(lang) {
            this.targetLanguage = lang;

            // 버튼 활성화 상태 변경
            $('.lang-btn').removeClass('active');
            $(`.lang-btn[data-lang="${lang}"]`).addClass('active');

            console.log('번역 대상 언어:', lang);

            // 상태 메시지 업데이트
            const langNames = {
                'ko': '한국어',
                'en': 'English',
                'ja': '日本語',
                'zh': '中文'
            };
            $('#targetLangStatus').text(langNames[lang]);
        },

        startListening:function(){
            // 마이크 초기화
            springai.voice.initMic(this);
        },

        handleVoice: async function(mp3Blob){
            // 스피너 보여주기
            $('#spinner').css('visibility','visible');

            // 멀티파트 폼 구성
            const formData = new FormData();
            formData.append("speech", mp3Blob, 'speech.mp3');
            formData.append("targetLang", this.targetLanguage); // 선택된 언어 전송

            try {
                // 음성 번역 요청
                const response = await fetch("/ai3/translate", {
                    method: "post",
                    headers: {
                        'Accept': 'application/json'
                    },
                    body: formData
                });

                // 번역 결과 받기
                const result = await response.json();
                console.log('번역 결과:', result);

                // 결과 표시 및 음성 재생
                this.showTranslation(result);

            } catch(error) {
                console.error('번역 오류:', error);
                alert('번역 중 오류가 발생했습니다: ' + error.message);
                $('#spinner').css('visibility','hidden');
                this.startListening();
            }
        },

        showTranslation: function(result){
            const langFlags = {
                'ko': '한국어',
                'en': 'English',
                'ja': '日本語',
                'zh': '中文'
            };

            // 번역 결과를 시각적으로 표시
            let translationForm =
                '<div class="translation-result">' +
                '<div class="text-box">' +
                '<div class="language-badge">' + (langFlags[result.detectedLang] || result.detectedLang) + '</div>' +
                '<div style="font-size: 1.1em;">' + result.originalText + '</div>' +
                '</div>' +
                '<div style="text-align: center; margin: 10px 0;">' +
                '<i class="bi bi-arrow-down" style="font-size: 1.5em;"></i>' +
                '</div>' +
                '<div class="text-box" style="background: rgba(255, 255, 255, 0.3);">' +
                '<div class="language-badge">' + (langFlags[result.targetLang] || result.targetLang) + '</div>' +
                '<div style="font-size: 1.2em; font-weight: bold;">' + result.translatedText + '</div>' +
                '</div>' +
                '</div>';

            $('#result').prepend(translationForm);

            // 번역된 음성 재생
            const audioPlayer = document.getElementById("audioPlayer");
            audioPlayer.src = "data:audio/mp3;base64," + result.audio;

            audioPlayer.addEventListener("ended", () => {
                $('#spinner').css('visibility','hidden');
                console.log("번역 완료");
                // 다음 음성 입력 대기
                this.startListening();
            }, { once: true });

            audioPlayer.play();
        }
    }

    $(()=>{
        translator.init();
    });
</script>

<div class="col-sm-10">
  <h2>실시간 통역</h2>
  <p class="text-muted">어떤 언어로 말해도 자동으로 감지하여 선택한 언어로 번역합니다</p>

  <!-- 언어 선택 섹션 -->
  <div class="language-selector">
    <h5 class="text-white mb-3">
      <i class="bi bi-translate"></i> 번역할 언어를 선택하세요
    </h5>
    <div class="btn-group-wrap text-center">
      <button class="btn btn-success lang-btn" data-lang="ko">
        🇰🇷 한국어
      </button>
      <button class="btn btn-success lang-btn active" data-lang="en">
        🇺🇸 English
      </button>
      <button class="btn btn-success lang-btn" data-lang="ja">
        🇯🇵 日本語
      </button>
      <button class="btn btn-success lang-btn" data-lang="zh">
        🇨🇳 中文
      </button>
    </div>
    <div class="alert alert-light mt-3 mb-0" role="alert">
      <strong>현재 번역 언어:</strong> <span id="targetLangStatus">English</span>
    </div>
  </div>

  <div class="row">
    <div class="col-sm-12">
      <div class="alert alert-info" role="alert">
        <strong>사용법:</strong>원하는 번역 언어를 선택한 후, 음성으로 말하면 자동으로 번역됩니다.
        <br>
        <strong>지원 언어:</strong> 한국어, English, 日本語, 中文
      </div>
    </div>
  </div>

  <div class="row">
    <div class="col-sm-10">
      <audio id="audioPlayer" controls style="display:none;"></audio>
    </div>
    <div class="col-sm-2">
      <button class="btn btn-secondary" disabled>
        <span class="spinner-border spinner-border-sm" id="spinner"></span>
        처리중..
      </button>
    </div>
  </div>

  <div id="result" class="container p-3 my-3 border"
       style="overflow-y: auto; overflow-x: hidden; width:100%; height: 500px; background-color: #f8f9fa;">
  </div>
</div>

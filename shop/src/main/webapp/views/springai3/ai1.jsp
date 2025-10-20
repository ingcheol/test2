<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    #result pre {
        white-space: pre-wrap;
        word-wrap: break-word;
        word-break: break-word;
        overflow-wrap: break-word;
        max-width: 100%;
        margin: 0;
        font-family: inherit;
    }

    #result .media-body {
        overflow: hidden;
        word-wrap: break-word;
        max-width: 100%;
    }

    #result img {
        max-width: 100%;
        height: auto;
    }

    /* 언어 선택 UI */
    .language-selector {
        background: rebeccapurple;
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 15px;
        color: white;
    }
</style>

<script>
    let ai6 = {
        CapturedBlob: null,
        currentLanguage: 'ko',   // 현재 선택된 언어

        init:function(){
            this.previewCamera('video');

            $('#send').click(()=>{
                this.captureFrame("video", (pngBlob) => {
                    this.CapturedBlob = pngBlob;
                    this.send(pngBlob);
                });
            });

            // 언어 변경 이벤트
            $('#language').change(() => {
                this.currentLanguage = $('#language').val();
            });

            $('#spinner').css('visibility','hidden');
        },

        previewCamera:function(videoId){
            const video = document.getElementById(videoId);
            navigator.mediaDevices.getUserMedia({ video: true })
                .then((stream) => {
                    video.srcObject = stream;
                    video.play();
                })
                .catch((error) => {
                    console.error('카메라 접근 에러:', error);
                    alert('카메라에 접근할 수 없습니다. 권한을 확인해주세요.');
                });
        },

        captureFrame:function(videoId, handleFrame){
            const video = document.getElementById(videoId);
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;

            const context = canvas.getContext('2d');
            context.drawImage(video, 0, 0, canvas.width, canvas.height);

            canvas.toBlob((blob) => {
                handleFrame(blob);
            }, 'image/png');
        },

        getPromptByLanguage: function(lang) {
            const prompts = {
                'ko': '너는 여행 중 동행하고 있는 전문 미술 및 역사 가이드야. 이미지 속 작품이나 유물을 한국어로 자세히 설명해줘. 작품의 이름과 작가 이름을 소개해주고 작품의 역사적 배경, 작가의 의도, 예술적 기법, 그리고 관련된 흥미로운 일화를 포함해서 마치 박물관에서 가이드가 직접 말로 설명하듯이 친근하게 이야기해줘. 중요: 답변은 음성으로 변환될 거니까 마크다운 형식이나 특수문자(#, *, -, 등)를 절대 사용하지 말고',

                'en': 'You are a professional art and history guide accompanying a traveler. Please explain the artwork or artifact in the image in English with detailed information about its historical background, the artist\'s intention, artistic techniques, and interesting anecdotes, as if you were speaking directly to visitors during a museum tour in a friendly conversational manner. Important: Your response will be converted to speech, so do not use any markdown formatting or special characters like hashtags, asterisks, or dashes.',

                'ja': 'あなたは旅行に同行しているプロの美術・歴史ガイドです。画像の作品や遺物について、歴史的背景、作家の意図、芸術的技法、そして関連する興味深いエピソードを含めて、まるで博物館で直接話しかけるように親しみやすく日本語で詳しく説明してください。重要：回答は音声に変換されるため、マークダウン形式や特殊文字（#、*、-など）は絶対に使用せず',

                'zh': '你是一位陪同旅行的专业艺术和历史导游。请用中文详细解释图像中的艺术品或文物，包括其历史背景、艺术家的意图、艺术技巧以及相关的有趣故事，就像在博物馆里直接对游客讲解一样，用亲切的对话方式。重要提示：你的回答将被转换为语音，因此请不要使用任何markdown格式或特殊字符（如#、*、-等）'
            };
            return prompts[lang] || prompts['ko'];
        },

        send: async function(pngBlob){
            $('#spinner').css('visibility','visible');

            const imageUrl = URL.createObjectURL(pngBlob);

            let captureForm = `
              <div class="media border p-3 mb-2">
                <div class="media-body">
                  <img src="`+imageUrl+`" alt="캡처 이미지" class="img-fluid" style="max-width:400px; border:1px solid #ddd; border-radius:5px;" />
                </div>
              </div>
            `;
            $('#result').prepend(captureForm);

            // 선택된 언어에 맞는 프롬프트 생성
            const question = this.getPromptByLanguage(this.currentLanguage);

            const formData = new FormData();
            formData.append("question", question);
            formData.append('attach', pngBlob, 'frame.png');
            formData.append('language', this.currentLanguage); // 언어 정보 전송

            try {
                const response = await fetch('/ai3/image-analysis2', {
                    method: "post",
                    headers: {
                        'Accept': 'application/json'
                    },
                    body: formData
                });

                const answerJson = await response.json();
                console.log(answerJson);

                const audioPlayer = document.getElementById("audioPlayer");
                audioPlayer.src = "data:audio/mp3;base64," + answerJson.audio;

                audioPlayer.addEventListener("play", () => {
                    let uuid = this.makeUi("result");
                    let answer = answerJson.text;
                    $('#'+uuid).html(answer);
                }, { once: true });

                audioPlayer.addEventListener("ended", () => {
                    $('#spinner').css('visibility','hidden');
                    console.log("대화 종료");
                    URL.revokeObjectURL(imageUrl);
                }, { once: true });

                audioPlayer.play();

            } catch(error) {
                console.error('이미지 분석 오류:', error);
                $('#spinner').css('visibility','hidden');

                const errorMessages = {
                    'ko': '이미지 분석 중 오류가 발생했습니다.',
                    'en': 'An error occurred during image analysis.',
                    'ja': '画像分析中にエラーが発生しました。',
                    'zh': '图像分析过程中发生错误。'
                };
                alert(errorMessages[this.currentLanguage] || errorMessages['ko']);
                URL.revokeObjectURL(imageUrl);
            }
        },

        makeUi:function(target){
            let uuid = "id-" + crypto.randomUUID();

            let aForm = `
              <div class="media border p-3 mb-2">
                <div class="media-body">
                  <pre id="`+uuid+`" style="background-color: #f8f9fa; padding: 10px; border-radius: 5px;"></pre>
                </div>
              </div>
            `;
            $('#'+target).prepend(aForm);
            return uuid;
        }
    }

    $(()=>{
        ai6.init();
    });
</script>

<div class="col-sm-10">
  <h2>작품 해설 AI</h2>

  <div class="row">
    <div class="col-sm-8">
      <!-- 언어 선택 영역 -->
      <div class="language-selector">
        <label for="language">Select Language</label>
        <select id="language" class="form-control">
          <option value="ko">한국어 (Korean)</option>
          <option value="en">English</option>
          <option value="ja">日本語 (Japanese)</option>
          <option value="zh">中文 (Chinese)</option>
        </select>
      </div>

      <div class="row mb-3">
        <div class="col-sm-12">
          <audio id="audioPlayer" controls style="display:none;"></audio>
        </div>
      </div>

      <div class="row mb-3">
        <div class="col-sm-3">
          <button type="button" class="btn btn-primary btn-block" id="send">
            <i class="bi bi-camera"></i> 캡처 및 해설
          </button>
        </div>
        <div class="col-sm-2">
          <button class="btn btn-secondary" disabled>
            <span class="spinner-border spinner-border-sm" id="spinner"></span>
            처리중..
          </button>
        </div>
      </div>

      <div id="result" class="container p-3 my-3 border" style="overflow-x: hidden; overflow-y: auto; width:100%; height: 500px; background-color: #f8f9fa;">
      </div>
    </div>

    <div class="col-sm-4">
      <div class="card">
          <h5 class="mb-0">카메라</h5>
        <div class="card-body p-0">
          <video id="video" class="img-fluid" style="width:100%; height:auto;" autoplay></video>
        </div>
      </div>
    </div>
  </div>
</div>

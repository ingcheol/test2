<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* pre 태그 텍스트 줄바꿈 설정 */
    #result pre {
        white-space: pre-wrap;
        word-wrap: break-word;
        word-break: break-word;
        overflow-wrap: break-word;
        max-width: 100%;
        margin: 0;
        font-family: inherit;
    }

    /* 결과 영역 텍스트 오버플로우 방지 */
    #result .media-body {
        overflow: hidden;
        word-wrap: break-word;
        max-width: 100%;
    }

    /* 캡처 이미지 반응형 */
    #result img {
        max-width: 100%;
        height: auto;
    }
</style>

<script>
    let ai6 = {
        init:function(){
            this.previewCamera('video');

            $('#send').click(()=>{
                this.captureFrame("video", (pngBlob) => {
                    this.send(pngBlob);
                });
            });

            $('#spinner').css('visibility','hidden');
        },

        previewCamera:function(videoId){
            const video = document.getElementById(videoId);
            // 카메라를 활성화하고 <video>에서 보여주기
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

            // 캔버스를 생성해서 비디오 크기와 동일하게 맞춤
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;

            // 캔버스로부터 2D로 드로잉하는 Context를 얻어냄
            const context = canvas.getContext('2d');

            // 비디오 프레임을 캔버스에 드로잉
            context.drawImage(video, 0, 0, canvas.width, canvas.height);

            // 드로잉된 프레임을 PNG 포맷의 blob 데이터로 얻기
            canvas.toBlob((blob) => {
                handleFrame(blob);
            }, 'image/png');
        },

        send: async function(pngBlob){
            $('#spinner').css('visibility','visible');

            // Blob을 이미지 URL로 변환하여 미리보기 표시
            const imageUrl = URL.createObjectURL(pngBlob);

            let captureForm = `
              <div class="media border p-3 mb-2">
                <div class="media-body">
                  <img src="`+imageUrl+`" alt="캡처 이미지" class="img-fluid" style="max-width:400px; border:1px solid #ddd; border-radius:5px;" />
                </div>
              </div>
            `;
            $('#result').prepend(captureForm);

            let question = '너는 여행 중 동행하고있는 미술 또는 역사 가이드 및 해설사야. 이미지를 나한테 음성으로 설명해줘. 관련된 역사나 이슈도 설명해주면 더 흥미롭게 들을수 있어';

            // 멀티파트 폼 구성하기
            const formData = new FormData();
            formData.append("question", question);
            formData.append('attach', pngBlob, 'frame.png');

            // AJAX 요청
            const response = await fetch('/ai3/image-analysis2', {
                method: "post",
                headers: {
                    'Accept': 'application/json'
                },
                body: formData
            });

            // 응답 JSON 받기
            const answerJson = await response.json();
            console.log(answerJson);

            // 음성 답변을 재생하기 위한 소스 설정
            const audioPlayer = document.getElementById("audioPlayer");
            audioPlayer.src = "data:audio/mp3;base64," + answerJson.audio;

            // 음성 답변이 재생 시작되면 콜백되는 함수 등록
            audioPlayer.addEventListener("play", () => {
                // 텍스트 답변을 채팅 패널에 보여주기
                let uuid = this.makeUi("result");
                let answer = answerJson.text;
                $('#'+uuid).html(answer);
            }, { once: true });

            // 음성 답변이 재생 완료되었을 때 콜백되는 함수 등록
            audioPlayer.addEventListener("ended", () => {
                // 스피너 숨기기
                $('#spinner').css('visibility','hidden');
                console.log("대화 종료");
                // Blob URL 메모리 해제
                URL.revokeObjectURL(imageUrl);
            }, { once: true });

            audioPlayer.play();
        },

        makeUi:function(target){
            let uuid = "id-" + crypto.randomUUID();

            let aForm = `
              <div class="media border p-3 mb-2">
                <div class="media-body">
                  <h6>AI 해설</h6>
                  <p><pre id="`+uuid+`"></pre></p>
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

  <div class="row">
    <div class="col-sm-8">
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

      <div id="result" class="container p-3 my-3 border" style="overflow: auto; width:auto; height: 500px; background-color: #f8f9fa;">
      </div>
    </div>

    <div class="col-sm-4">
      <div class="card">
        <div class="card-body p-0">
          <video id="video" class="img-fluid" style="width:100%; height:auto;" autoplay></video>
        </div>
      </div>
    </div>
  </div>
</div>

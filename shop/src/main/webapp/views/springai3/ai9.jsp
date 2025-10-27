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

  .recognition-status {
    padding: 15px;
    border-radius: 10px;
    margin-bottom: 15px;
    display: none;
  }

  .status-success {
    background: #d4edda;
    border: 2px solid #28a745;
    color: #155724;
  }

  .status-fail {
    background: #f8d7da;
    border: 2px solid #dc3545;
    color: #721c24;
  }
</style>

<script>
  let ai6 = {
    CapturedBlob: null,
    adminServerUrl: '${adminserver}',

    init:function(){
      this.previewCamera('video');

      $('#send').click(()=>{
        this.captureFrame("video", (pngBlob) => {
          this.CapturedBlob = pngBlob;
          this.send(pngBlob);
        });
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

    // Blob 객체를 Base64 문자열로 변환하는 유틸리티 함수 추가
    blobToBase64: function(blob) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onloadend = () => {
          // "data:image/png;base64," 접두사 제거
          const base64String = reader.result.replace(/^data:image\/(png|jpeg|jpg);base64,/, '');
          resolve(base64String);
        };
        reader.onerror = reject;
        reader.readAsDataURL(blob);
      });
    },

    send: async function(pngBlob){
      $('#spinner').css('visibility','visible');
      $('.recognition-status').hide();

      const imageUrl = URL.createObjectURL(pngBlob);

      let captureForm = `
        <div class="media border p-3 mb-2">
          <div class="media-body">
            <img src="`+imageUrl+`" alt="캡처 이미지" class="img-fluid" style="max-width:400px; border:1px solid #ddd; border-radius:5px;" />
          </div>
        </div>
      `;
      $('#result').prepend(captureForm);

      const formData = new FormData();
      // Shop 서버의 AI는 MultipartFile을 기대할 수 있으므로 FormData를 사용합니다.
      formData.append('attach', pngBlob, 'carplate.png');

      try {
        // ===== Shop 서버의 차량 인식 API 호출 (기존 로직 유지) =====
        const response = await fetch('/ai5/boom-barrier-tools', {
          method: "POST",
          body: formData
        });

        const answerText = await response.text();
        console.log('차량 인식 결과:', answerText);

        let uuid = this.makeUi("result");
        $('#'+uuid).html(answerText);

        // ===== 차량 인식 성공 여부 판단 =====
        const isSuccess = answerText.includes('차단기 올림');

        if(isSuccess) {
          // 등록된 차량 - 성공 메시지
          $('#statusMessage').removeClass('status-fail').addClass('status-success');
          $('#statusMessage').html(`
            <h5>✅ 등록된 차량입니다!</h5>
            <p>차단기를 올립니다. 안전한 주차 되세요..</p>
          `);
        } else {
          // 미등록 차량 - 실패 메시지
          $('#statusMessage').removeClass('status-success').addClass('status-fail');
          $('#statusMessage').html(`
            <h5>❌ 등록되지 않은 차량입니다</h5>
            <p>차단기를 내립니다.</p>
          `);
        }
        $('#statusMessage').fadeIn();

        // ===== Base64 이미지와 함께 Admin 서버로 차량 인식 결과 전송 (SSE 연동을 위해 Base64 사용) =====
        await this.sendToAdminServer(pngBlob, answerText, isSuccess);

        $('#spinner').css('visibility','hidden');
        URL.revokeObjectURL(imageUrl);

      } catch(error) {
        console.error('차량 인식 오류:', error);
        $('#spinner').css('visibility','hidden');
        alert('차량 인식 중 오류가 발생했습니다.');
        URL.revokeObjectURL(imageUrl);
      }
    },

    // ===== Admin 서버로 데이터 전송 (Base64 변환 및 JSON 전송 로직으로 변경) =====
    sendToAdminServer: async function(pngBlob, recognitionResult, isSuccess){
      try {
        // Blob을 Base64 문자열로 변환
        const base64Image = await this.blobToBase64(pngBlob);

        // 차량 번호 추출 (예: "23가4567")
        const carNumberMatch = recognitionResult.match(/\d{2,3}[가-힣]\d{4}/);
        const carNumber = carNumberMatch ? carNumberMatch[0] : '미인식';

        // 전송할 JSON 데이터 구조
        const messageData = {
          type: isSuccess ? 'CAR_ENTRY' : 'CAR_DENIED',
          carNumber: carNumber,
          // Admin 서버에서 SSE 메시지로 사용될 결과 텍스트
          message: recognitionResult,
          timestamp: new Date().toISOString(),
          // Base64 이미지 데이터를 필드로 추가
          base64File: base64Image
        };

        // JSON 형태로 POST 요청
        const response = await fetch(this.adminServerUrl + 'aimsg2', {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify(messageData)
        });

        if(response.ok){
          console.log('✅ Admin 서버로 차량 정보 전송 성공');
        } else {
          console.log('❌ Admin 서버 전송 실패');
        }
      } catch(error) {
        console.error('Admin 서버 전송 오류:', error);
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
  <h2>🚗 스마트 주차 시스템</h2>

  <div class="row">
    <div class="col-sm-8">
      <div class="recognition-status" id="statusMessage"></div>

      <div class="row mb-3">
        <div class="col-sm-3">
          <button type="button" class="btn btn-primary btn-block" id="send">
            <i class="bi bi-camera"></i> 차량번호판 인식
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

      <div class="card mt-3">
        <div class="card-header bg-info text-white">
          📋 등록된 차량 번호
        </div>
        <div class="card-body">
          <div class="d-flex flex-wrap gap-2">
            <span class="badge badge-primary p-2">23가4567</span>
            <span class="badge badge-primary p-2">234부8372</span>
            <span class="badge badge-primary p-2">345가6789</span>
            <span class="badge badge-primary p-2">157고4895</span>
            <span class="badge badge-primary p-2">368러2704</span>
          </div>
        </div>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="card">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0">📹 카메라</h5>
        </div>
        <div class="card-body p-0">
          <video id="video" class="img-fluid" style="width:100%; height:auto;" autoplay></video>
        </div>
      </div>
    </div>
  </div>
</div>
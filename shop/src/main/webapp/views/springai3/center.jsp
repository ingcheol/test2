<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
  let center = {
      init:function (){
          this.previewCamera('video');
          $('#send').click(()=>{
              this.captureFrame("video", (pngBlob) => {
                  this.send(pngBlob);
              });
          });
          // $('#send_btn').click(()=>{
          //     let msg = 'test---';
          //     this.send(msg);
          // })
      },
      <%--send:function (msg){--%>
      <%--    $.ajax({--%>
      <%--        url:'${adminserver}aimsg',--%>
      <%--        data:{msg:msg},--%>
      <%--        success:()=>{}--%>
      <%--    })--%>
      <%--}--%>
      previewCamera:function(videoId){
          const video = document.getElementById(videoId);
          //카메라를 활성화하고 <video>에서 보여주기
          navigator.mediaDevices.getUserMedia({ video: true })
              .then((stream) => {
                  video.srcObject = stream;
                  video.play();
              })
              .catch((error) => {
                  console.error('카메라 접근 에러:', error);
              });
      },
      captureFrame:function(videoId, handleFrame){
          const video = document.getElementById(videoId);

          //캔버스를 생성해서 비디오 크기와 동일하게 맞춤
          const canvas = document.createElement('canvas');
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;

          // 캔버스로부터  2D로 드로잉하는 Context를 얻어냄
          const context = canvas.getContext('2d');

          // 비디오 프레임을 캔버스에 드로잉
          context.drawImage(video, 0, 0, canvas.width, canvas.height);

          // 드로잉된 프레임을 PNG 포맷의 blob 데이터로 얻기
          canvas.toBlob((blob) => {
              handleFrame(blob);
          }, 'image/png');
      },
      send: function(pngBlob){
          // Blob을 이미지 URL로 변환
          const imageUrl = URL.createObjectURL(pngBlob);

          let qForm = `
      <div class="media border p-3">
          <img src="`+imageUrl+`" alt="캡처 이미지" style="max-width:400px; border:1px solid #ddd; border-radius:5px;" />
        </div>
      </div>
    `;
          $('#result').prepend(qForm);

          const formData = new FormData();
          formData.append('image', pngBlob, 'capture.png');

          $.ajax({
              url: '${adminserver}aiimage',
              type: 'POST',
              data: formData,
              processData: false,
              contentType: false,
              success: function(response){
                  console.log('전송 성공:', response);
                  URL.revokeObjectURL(imageUrl);
              },
              error: function(error){
                  console.error('전송 실패:', error);
                  URL.revokeObjectURL(imageUrl);
              }
          });
      },
  }
  $(()=>{
      center.init();
  })
</script>

<div class="col-sm-10">
  <h2>AI3 voice Image Chat System</h2>
  <h5>${adminserver}</h5>
  <button id="send">Click</button>

  <div id="result" class="container p-3 my-3 border" style="overflow: auto;width:auto;height: 300px;">
  </div>
  <video id="video" src="" height="200" autoplay />

</div>

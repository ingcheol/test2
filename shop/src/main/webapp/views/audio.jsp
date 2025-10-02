<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>

  let ad = {
    mediaRecorder:null,
    audioChunks:[],
    audioBlob:null,
    init:function(){
      $('#sendBtn').attr({disabled:true});
      $('#recordBtn').click(()=>{
        navigator.mediaDevices.getUserMedia({ audio: true })
                .then(stream => {
                  this.mediaRecorder = new MediaRecorder(stream);

                  this.mediaRecorder.addEventListener("stop", () => {
                    $('#sendBtn').attr({disabled:false});
                  });
                  this.mediaRecorder.start();

                  this.audioChunks = [];
                  $('#recordBtn').attr({disabled:true});
                  $('#stopBtn').attr({disabled:false});
                  $('#statusMessage').html("Recording...");

                  this.mediaRecorder.addEventListener("dataavailable", event => {
                    this.audioChunks.push(event.data);
                  });

                  this.mediaRecorder.addEventListener("stop", () => {
                    this.audioBlob = new Blob(this.audioChunks, { type: 'audio/mp3' });
                    const audioUrl = URL.createObjectURL(this.audioBlob);
                    $('#audioPlayback').attr({src: audioUrl});
                    $('#statusMessage').html("Recording complete. Click play to listen.");
                    $('#recordBtn').attr({disabled:false});
                    $('#stopBtn').attr({disabled:true});
                    this.sendData();
                  });
                })
                .catch(error => {
                  console.error('Error accessing microphone:', error);
                  $('#statusMessage').html("Error: Unable to access microphone.");
                });
      });
      $('#stopBtn').click(()=>{
        if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
          this.mediaRecorder.stop();
          $('#statusMessage').html("Recording stopped.");
        }
      });
      $('#sendBtn').click(()=>{
        this.sendData();
      });
    },
    sendData:function(){
      if (this.audioBlob) {
        const fileName = 'audio_' + new Date().getMilliseconds() + '.mp3';
        let formData = new FormData();
        formData.append('file', this.audioBlob, fileName);
        $.ajax({
          type: 'post',
          url: '/saveaudio',
          enctype: 'multipart/form-data',
          cache: false,
          data: formData,
          processData: false,
          contentType: false,
          success: function (data) {
            alert(data);
          }
        });
      } else {
        statusMessage.textContent = "No audio recorded to send.";
      }
    }

  }

  $(function(){
    ad.init();
  });

</script>



<div class="col-sm-10">
  <h1>Voice Recorder</h1>
  <div class="recorder">
    <button id="recordBtn" class="button record">Record</button>
    <button id="stopBtn" class="button stop" disabled>Stop</button>
    <audio id="audioPlayback" controls></audio>
    <button id="sendBtn" class="button send" disabled>Send to Server</button>
  </div>
  <p id="statusMessage"></p>
</div>

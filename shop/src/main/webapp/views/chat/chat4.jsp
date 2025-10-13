<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  .admin-webrtc-container{max-width:1200px;margin:0 auto;padding:20px}
  .video-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:20px;margin-bottom:20px}
  .video-wrapper{position:relative;width:100%;background:#000;border-radius:8px;overflow:hidden}
  .video-stream{width:100%;height:auto;aspect-ratio:16/9}
  .video-label{position:absolute;bottom:10px;left:10px;color:white;background:rgba(0,0,0,0.5);padding:5px 10px;border-radius:4px}
  .controls{display:flex;justify-content:center;gap:10px;margin:20px 0}
  .control-button{padding:10px 20px;border-radius:4px;border:none;cursor:pointer;font-size:16px}
  .start-call{background:#4CAF50;color:white}
  .end-call{background:#f44336;color:white}
  .connection-status{text-align:center;font-size:14px}

  /* 채팅 스타일 */
  .chat-container{margin-top:20px;border:1px solid #ddd;background:#b2c7d9;border-radius:8px;overflow:hidden}
  .chat-header{background:#3a5a78;color:white;padding:15px;font-weight:bold}
  .chat-messages{height:400px;overflow-y:auto;padding:20px;background:#b2c7d9}
  .message{display:flex;margin-bottom:15px;align-items:flex-end}
  .message.sent{justify-content:flex-end}
  .message.received{justify-content:flex-start}
  .message-bubble{max-width:60%;padding:10px 15px;border-radius:18px;word-wrap:break-word;position:relative}
  .message.sent .message-bubble{background:#ffe600;color:#000}
  .message.received .message-bubble{background:#fff;color:#000}
  .message-sender{font-size:11px;color:#555;margin-bottom:3px;padding:0 5px}
  .message.sent .message-sender{text-align:right}
  .message.received .message-sender{text-align:left}
  .message-time{font-size:10px;color:#666;margin:0 5px;align-self:flex-end;margin-bottom:5px}
  .chat-input-area{display:flex;padding:15px;background:#fff;border-top:1px solid #ddd}
  .chat-input-area input{flex:1;padding:10px;border:1px solid #ddd;border-radius:20px;outline:none;font-size:14px}
  .chat-input-area button{margin-left:10px;padding:10px 20px;background:#ffe600;border:none;border-radius:20px;cursor:pointer;font-weight:bold}
  .chat-input-area button:hover{background:#ffd700}
</style>

<script>
  chat4 = {
    // Chat2 변수
    id:'',
    stompClient:null,

    // Chat3 변수
    roomId:'1',
    peerConnection:null,
    localStream:null,
    websocket:null,
    configuration:{iceServers:[{urls:'stun:stun.l.google.com:19302'}]},

    init:async function(){
      // Chat2 초기화
      this.id = '${sessionScope.cust.custId}';
      this.connectChat();

      // Chat3 초기화
      $('#startButton').click(()=>this.startCall());
      $('#endButton').click(()=>this.endCall());
      await this.startCam();
      await this.connectWebRTC();
      $('#adminArea').hide();

      // 채팅 전송
      $('#sendto').click(()=>this.sendMessage());
      $('#totext').keypress((e)=>{
        if(e.which === 13){
          this.sendMessage();
        }
      });
    },

    sendMessage:function(){
      const msg = $('#totext').val().trim();
      if(!msg) return;

      var msgData = JSON.stringify({
        'sendid':this.id,
        'receiveid':$('#target').val(),
        'content1':msg
      });
      this.stompClient.send('/adminreceiveto',{},msgData);

      // 내가 보낸 메시지 표시
      this.addMessage(msg, 'sent', this.id);
      $('#totext').val('');
    },

    addMessage:function(content, type, sender){
      const time = new Date().toLocaleTimeString('ko-KR', {hour:'2-digit', minute:'2-digit'});
      let messageHtml = '<div class="message ' + type + '">';
      if(type === 'received'){
        messageHtml += '<div class="message-sender">' + sender + '</div>';
      }
      messageHtml += '<div class="message-bubble">' + content + '</div>';
      messageHtml += '<div class="message-time">' + time + '</div>';
      messageHtml += '</div>';

      $('#chatMessages').append(messageHtml);
      $('#chatMessages').scrollTop($('#chatMessages')[0].scrollHeight);
    },

    // ===== Chat2 관련 메서드 =====
    connectChat:function(){
      let sid = this.id;
      let socket = new SockJS('${websocketurl}adminchat');
      this.stompClient = Stomp.over(socket);

      // ⭐ 수정: chat4 참조를 명확히 함
      let self = this;

      this.stompClient.connect({}, function(frame){
        console.log('Chat Connected: ' + frame);
        self.setChatConnected(true);

        // ⭐ 핵심 수정: this 대신 self.stompClient 사용
        self.stompClient.subscribe('/adminsend/to/' + sid, function(msg){
          const data = JSON.parse(msg.body);
          console.log('Received message from admin:', data);  // 디버깅용 로그
          chat4.addMessage(data.content1, 'received', data.sendid);
        });
      }, function(error){
        // ⭐ 에러 핸들링 추가
        console.error('STOMP connection error:', error);
        self.setChatConnected(false);
      });
    },

    setChatConnected:function(connected){
      $("#status").text(connected?"Connected":"Disconnected");
    },

    // ===== Chat3 관련 메서드 =====
    connectWebRTC:function(){
      try{
        this.websocket = new WebSocket('${websocketurl}signal');
        this.websocket.onopen = ()=>{
          console.log('WebSocket connected');
          this.updateConnectionStatus('WebSocket Connected');
          this.sendSignalingMessage({type:'join',roomId:this.roomId});
        };
        this.setupWebSocketHandlers();
      }catch(error){
        console.error('Error initializing WebRTC:',error);
        this.updateConnectionStatus('Error: '+error.message);
      }
    },

    startCam:async function(){
      const stream = await navigator.mediaDevices.getUserMedia({
        video:{width:{ideal:1280},height:{ideal:720}},
        audio:true
      });
      this.localStream = stream;
      document.getElementById('localVideo').srcObject = stream;
      document.getElementById('startButton').disabled = false;
    },

    startCall:async function(){
      try{
        if(!this.peerConnection){
          await this.startCam();
          await this.createPeerConnection();
          this.sendSignalingMessage({type:'join',data:'Hi ..',roomId:this.roomId});
        }
        const offer = await this.peerConnection.createOffer();
        await this.peerConnection.setLocalDescription(offer);
        this.sendSignalingMessage({type:'offer',data:offer,roomId:this.roomId});
        $('#startButton').hide();
        $('#endButton').show();
        $('#adminArea').show();
      }catch(error){
        console.error('Error starting call:',error);
        this.updateConnectionStatus('Error starting call');
      }
    },

    endCall:function(){
      if(this.localStream){
        this.localStream.getTracks().forEach(track=>track.stop());
      }
      if(this.peerConnection){
        this.peerConnection.close();
        this.peerConnection = null;
      }
      document.getElementById('remoteVideo').srcObject = null;
      $('#adminArea').hide();
      $('#startButton').show();
      $('#endButton').hide();
      this.updateConnectionStatus('Call Ended');
      $('#user').html("접속이 끊어 졌습니다.");
      this.sendSignalingMessage({type:'bye',roomId:this.roomId});
    },

    sendSignalingMessage:function(message){
      if(this.websocket?.readyState === WebSocket.OPEN){
        this.websocket.send(JSON.stringify(message));
      }
    },

    setupWebSocketHandlers:function(){
      this.websocket.onmessage = async(event)=>{
        try{
          const message = JSON.parse(event.data);
          console.log('Received message:',message.type);
          switch(message.type){
            case 'offer':
              if(!this.peerConnection){
                await this.createPeerConnection();
              }
              await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
              const answer = await this.peerConnection.createAnswer();
              await this.peerConnection.setLocalDescription(answer);
              this.sendSignalingMessage({type:'answer',data:answer,roomId:this.roomId});
              break;
            case 'join':
              $('#user').html("사용자가 방문 하였습니다. Start Call 버튼을 누르세요");
              $('#adminArea').show();
              break;
            case 'bye':
              $('#user').html("접속이 끊어 졌습니다.");
              document.getElementById('remoteVideo').srcObject = null;
              $('#adminArea').hide();
              break;
            case 'answer':
              await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
              break;
            case 'ice-candidate':
              $('#startButton').hide();
              $('#endButton').show();
              await this.peerConnection.addIceCandidate(new RTCIceCandidate(message.data));
              $('#user').html("연결 되었습니다.");
              break;
          }
        }catch(error){
          console.error('Error handling WebSocket message:',error);
        }
      };
      this.websocket.onclose = ()=>{
        console.log('WebSocket Disconnected');
        this.updateConnectionStatus('WebSocket Disconnected');
      };
      this.websocket.onerror = (error)=>{
        console.error('WebSocket error:',error);
        this.updateConnectionStatus('WebSocket Error');
      };
    },

    createPeerConnection:function(){
      this.peerConnection = new RTCPeerConnection(this.configuration);
      this.localStream.getTracks().forEach(track=>{
        this.peerConnection.addTrack(track,this.localStream);
      });
      this.peerConnection.ontrack = (event)=>{
        if(document.getElementById('remoteVideo') && event.streams[0]){
          document.getElementById('remoteVideo').srcObject = event.streams[0];
        }
      };
      this.peerConnection.onicecandidate = (event)=>{
        if(event.candidate){
          this.sendSignalingMessage({type:'ice-candidate',data:event.candidate,roomId:this.roomId});
        }
      };
      this.peerConnection.onconnectionstatechange = ()=>{
        this.updateConnectionStatus('Connection: '+this.peerConnection.connectionState);
      };
      return this.peerConnection;
    },

    updateConnectionStatus:function(status){
      document.getElementById('connectionStatus').textContent = 'Status: '+status;
    }
  }

  $(()=>chat4.init());

  window.onbeforeunload = function(e){
    e.preventDefault();
    chat4.endCall();
  };
</script>

<div class="col-sm-10">
  <h2>여행 관리자와 1대1 대화</h2>
  <h4 id="user">Start Call 버튼을 누르세요</h4>

  <!-- 영상통화 영역 -->
  <div class="admin-webrtc-container">
    <div class="video-grid">
      <div class="video-wrapper" id="adminArea">
        <video id="remoteVideo" autoplay playsinline muted class="video-stream"></video>
        <div class="video-label">Admin Stream</div>
      </div>
      <div class="video-wrapper">
        <video id="localVideo" autoplay playsinline class="video-stream"></video>
        <div class="video-label">User Stream</div>
      </div>
    </div>
    <div class="controls">
      <button id="startButton" class="control-button start-call">Start Call</button>
      <button id="endButton" class="control-button end-call" style="display:none;">End Call</button>
    </div>
    <div class="connection-status" id="connectionStatus">Status: Disconnected</div>
  </div>

  <!-- 채팅 영역 -->
  <div class="chat-container">
    <div class="chat-header">
      💬 관리자와의 채팅 ${sessionScope.cust.custId}
      <span style="float:right;font-size:12px;font-weight:normal">Status: <span id="status">Disconnected</span></span>
    </div>
    <div class="chat-messages" id="chatMessages">
      <!-- 메시지가 여기에 표시됩니다 -->
    </div>
    <div class="chat-input-area">
      <input type="hidden" id="target" value="admin">
      <input type="text" id="totext" placeholder="메시지를 입력하세요..." autocomplete="off">
      <button id="sendto">전송</button>
    </div>
  </div>
</div>
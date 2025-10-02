<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #all {
    width: 400px;
    height: 200px;
    overflow: auto;
    border: 2px solid red;
  }

  #me {
    width: 400px;
    height: 200px;
    overflow: auto;
    border: 2px solid blue;
  }

  #to {
    width: 400px;
    height: 200px;
    overflow: auto;
    border: 2px solid green;
  }
</style>

<script>
  let chat1 = {
    id:'',
    stompClient:null,
    init:function(){
      this.id = $('#user_id').text();
      $('#connect').click(()=>{
        this.connect();
      });
      $('#disconnect').click(()=>{
        this.disconnect();
      });
      $('#sendall').click(()=>{
        let msg = JSON.stringify({
          'sendid' : this.id,
          'content1' : $("#alltext").val()
        });
        this.stompClient.send("/receiveall", {}, msg);
      });
      $('#sendme').click(()=>{
        let msg = JSON.stringify({
          'sendid' : this.id,
          'content1' : $("#metext").val()
        });
        this.stompClient.send("/receiveme", {}, msg);
      });
      $('#sendto').click(()=>{
        var msg = JSON.stringify({
          'sendid' : this.id,
          'receiveid' : $('#target').val(),
          'content1' : $('#totext').val()
        });
        this.stompClient.send('/receiveto', {}, msg);
      });


    },
    connect:function(){
      let sid = this.id;
      let socket = new SockJS('${websocketurl}chat');
      this.stompClient = Stomp.over(socket);
      this.setConnected(true);
      this.stompClient.connect({}, function(frame) {
        console.log('Connected: ' + frame);
        this.subscribe('/send', function(msg) {
          $("#all").prepend(
                  "<h4>" + JSON.parse(msg.body).sendid +":"+
                  JSON.parse(msg.body).content1
                  + "</h4>");
        });
        this.subscribe('/send/'+sid, function(msg) {
          $("#me").prepend(
                  "<h4>" + JSON.parse(msg.body).sendid +":"+
                  JSON.parse(msg.body).content1+ "</h4>");
        });
        this.subscribe('/send/to/'+sid, function(msg) {
          $("#to").prepend(
                  "<h4>" + JSON.parse(msg.body).sendid +":"+
                  JSON.parse(msg.body).content1
                  + "</h4>");
        });

      });
    },
    disconnect:function(){
      if (this.stompClient !== null) {
        this.stompClient.disconnect();
      }
      this.setConnected(false);
      console.log("Disconnected");
    },
    setConnected:function(connected){
      if (connected) {
        $("#status").text("Connected");
      } else {
        $("#status").text("Disconnected");
      }
    }

  }
  $(()=>{
    chat1.init();
  })
</script>



<div class="col-sm-10">
  <h2>Chat1 Center</h2>
  <div class="card-body">
    <div class="table-responsive">
      <div class="col-sm-5">
        <h1 id="user_id">${sessionScope.cust.custId}</h1>
        <H1 id="status">Status</H1>
        <button id="connect">Connect</button>
        <button id="disconnect">Disconnect</button>

        <h3>All</h3>
        <input type="text" id="alltext"><button id="sendall">Send</button>
        <div id="all"></div>

        <h3>Me</h3>
        <input type="text" id="metext"><button id="sendme">Send</button>
        <div id="me"></div>

        <h3>To</h3>
        <input type="text" id="target">
        <input type="text" id="totext"><button id="sendto">Send</button>
        <div id="to"></div>

      </div>
    </div>

</div>
</div>
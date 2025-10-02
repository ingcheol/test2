<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #to {
    width: 400px;
    height: 200px;
    overflow: auto;
    border: 2px solid green;
  }
</style>
<script>
  chat2 = {
    id:'',
    init:function(){
      this.id = '${sessionScope.cust.custId}';
      this.connect();
      $('#sendto').click(()=>{
        var msg = JSON.stringify({
          'sendid' : this.id,
          'receiveid' : $('#target').val(),
          'content1' : $('#totext').val()
        });
        this.stompClient.send('/adminreceiveto', {}, msg);
      });
    },
    connect:function(){
      let sid = this.id;
      let socket = new SockJS('${websocketurl}adminchat');
      this.stompClient = Stomp.over(socket);
      this.setConnected(true);
      this.stompClient.connect({}, function(frame) {
          console.log('Connected: ' + frame);

          this.subscribe('/adminsend/to/'+sid, function(msg) {
            $("#to").prepend(
                    "<h4>" + JSON.parse(msg.body).sendid +":"+
                    JSON.parse(msg.body).content1
                    + "</h4>");
          });
      });
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
    chat2.init();
  });
</script>

<div class="col-sm-10">
  <h2>Chat1 Center</h2>
  <div class="card-body">
    <div class="table-responsive">
      <div class="col-sm-5">
        <h1 id="user_id">${sessionScope.cust.custId}</h1>
        <H1 id="status">Status</H1>

        <h3>To</h3>
        <input type="text" id="target" value="admin">
        <input type="text" id="totext"><button id="sendto">Send</button>
        <div id="to"></div>

      </div>
    </div>

  </div>
</div>

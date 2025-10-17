<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    let ai3 = {
        init:function(){
            $('#send').click(()=>{
                this.send();
            });
            $('#spinner').css('visibility','hidden');
        },
        send: async function(){
            $('#spinner').css('visibility','visible');

            let question = $('#question').val();
            let qForm = `
            <div class="media border p-3">
              <img src="/image/user.png" alt="John Doe" class="mr-3 mt-3 rounded-circle" style="width:60px;">
              <div class="media-body">
                <h6>John Doe</h6>
                <p>`+question+`</p>
              </div>
            </div>
    `;
            $('#result').prepend(qForm);

            const response = await fetch('/ai1/chat-of-thought', {
                method: "post",
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/x-ndjson' //라인으로 구분된 청크 텍스트
                },
                body: new URLSearchParams({ question })
            });

            let uuid = this.makeUi("result");

            const reader = response.body.getReader();
            const decoder = new TextDecoder("utf-8");
            let content = "";
            while (true) {
                const {value, done} = await reader.read();
                if (done) break;
                let chunk = decoder.decode(value);
                content += chunk;
                console.log(content);
                $('#'+uuid).html(content)
            }
            $('#spinner').css('visibility','hidden');

        },
        makeUi:function(target){
            let uuid = "id-" + crypto.randomUUID();

            let aForm = `
          <div class="media border p-3">
            <div class="media-body">
              <h6>GPT4 </h6>
              <p><pre id="`+uuid+`"></pre></p>
            </div>
            <img src="/image/assistant.png" alt="John Doe" class="ml-3 mt-3 rounded-circle" style="width:60px;">
          </div>
    `;
            $('#'+target).prepend(aForm);
            return uuid;
        }

    }

    $(()=>{
        ai3.init();
    });

</script>

<div class="col-sm-10">
    <h2>AI3 Chat System</h2>
    <div class="row">
        <div class="col-sm-8">
            <textarea id="question" class="form-control">제가 3살일 때, 제 파트너는 제 나이의 3배였어요. 지금 저는 20살인데, 제 파트너는 몇 살일까요?</textarea>
        </div>
        <div class="col-sm-2">
            <button type="button" class="btn btn-primary" id="send">Send</button>
        </div>
        <div class="col-sm-2">
            <button class="btn btn-primary" disabled >
                <span class="spinner-border spinner-border-sm" id="spinner"></span>
                Loading..
            </button>
        </div>
    </div>

    <div id="result" class="container p-3 my-3 border" style="overflow: auto;width:auto;height: 300px;">
    </div>

</div>
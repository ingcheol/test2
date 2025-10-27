<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* 탭 UI 및 카메라/업로드 영역 */
    #videoContainer {
        position: relative;
        width: 100%;
    }
    #video {
        width: 100%;
        border: 2px solid #ddd;
        border-radius: 8px;
    }
    #canvas {
        display: none;
    }
    .camera-controls {
        text-align: center;
        margin-top: 10px;
    }
    .tab-buttons {
        margin-bottom: 20px;
    }
    .preview-image {
        max-width: 100%;
        border-radius: 8px;
        margin-top: 10px;
    }

    /* 언어 선택 UI */
    .language-selector {
        background: #007bff;
        border-radius: 10px;
        padding: 15px;
        margin-bottom: 15px;
        color: white;
    }

    /* 결과 표시 UI */
    .inspection-result {
        background-color: #f8f9fa;
        border-left: 5px solid #007bff;
        padding: 15px;
        margin: 10px 0;
        font-size: 1.1em;
        line-height: 1.6;
        white-space: pre-wrap;
        word-wrap: break-word;
    }
    .inspection-result.alert-danger {
        border-left-color: #dc3545;
        background-color: #fbeeed;
    }
    .inspection-result.alert-warning {
        border-left-color: #ffc107;
        background-color: #fff8e6;
    }
    .inspection-result.alert-success {
        border-left-color: #28a745;
        background-color: #eaf6ec;
    }

    /* 결과 컨테이너 내부 pre 태그 스타일 */
    #resultContainer pre {
        white-space: pre-wrap;
        word-wrap: break-word;
        word-break: break-word;
        overflow-wrap: break-word;
        max-width: 100%;
        margin: 0;
        font-family: inherit;
        background-color: transparent;
        border: none;
        padding: 0;
    }
</style>

<script>
    let vehicleAi = {
        stream: null,
        currentLanguage: 'ko',
        capturedBlob: null,
        uploadedFile: null,
        currentMode: 'camera',

        init: function(){
            // 탭 전환
            $('#cameraTab').click(() => {
                this.showTab('camera');
            });
            $('#uploadTab').click(() => {
                this.showTab('upload');
            });

            // 카메라 제어
            $('#startCamera').click(() => {
                this.startCamera();
            });
            $('#captureBtn').click(() => {
                this.captureImage();
            });
            $('#stopCamera').click(() => {
                this.stopCamera();
            });

            // 파일 업로드
            $('#attach').change((e) => {
                this.uploadedFile = e.target.files[0];
                this.previewUploadedImage(this.uploadedFile);
            });

            // 검사 버튼
            $('#sendCamera').click(() => {
                this.currentMode = 'camera';
                this.sendForInspection();
            });
            $('#sendUpload').click(() => {
                this.currentMode = 'upload';
                this.sendForInspection();
            });

            // 언어 변경
            $('#language').change(() => {
                this.currentLanguage = $('#language').val();
            });

            $('#spinner').css('visibility','hidden');
            this.showTab('camera');
        },

        showTab: function(tab){
            if(tab === 'camera') {
                $('#cameraSection').show();
                $('#uploadSection').hide();
                $('#cameraTab').addClass('active btn-primary').removeClass('btn-outline-primary');
                $('#uploadTab').removeClass('active btn-primary').addClass('btn-outline-primary');
                this.currentMode = 'camera';
            } else {
                $('#cameraSection').hide();
                $('#uploadSection').show();
                $('#cameraTab').removeClass('active btn-primary').addClass('btn-outline-primary');
                $('#uploadTab').addClass('active btn-primary').removeClass('btn-outline-primary');
                this.stopCamera();
                this.currentMode = 'upload';
            }
        },

        startCamera: async function(){
            try {
                this.stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: 'environment' }
                });
                $('#video')[0].srcObject = this.stream;
                $('#startCamera').hide();
                $('#captureBtn, #stopCamera').show();
            } catch(err) {
                alert('카메라에 접근할 수 없습니다: ' + err.message);
            }
        },

        captureImage: function(){
            const video = $('#video')[0];
            const canvas = $('#canvas')[0];
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0);

            canvas.toBlob((blob) => {
                this.capturedBlob = blob;
                const imgData = URL.createObjectURL(blob);
                $('#capturedImage').attr('src', imgData).show();
                $('#sendCamera').prop('disabled', false);
            }, 'image/jpeg', 0.9);
        },

        stopCamera: function(){
            if(this.stream) {
                this.stream.getTracks().forEach(track => track.stop());
                this.stream = null;
                $('#video')[0].srcObject = null;
                $('#startCamera').show();
                $('#captureBtn, #stopCamera').hide();
                $('#capturedImage').attr('src', '').hide();
                this.capturedBlob = null;
                $('#sendCamera').prop('disabled', true);
            }
        },

        previewUploadedImage: function(file){
            if(file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    $('#uploadPreview').attr('src', e.target.result).show();
                    $('#sendUpload').prop('disabled', false);
                };
                reader.readAsDataURL(file);
            } else {
                $('#uploadPreview').attr('src', '').hide();
                $('#sendUpload').prop('disabled', true);
            }
        },

        getPromptByLanguage: function(lang) {
            const prompts = {
                'ko': '너는 환경부 소속의 재활용품 분류 전문가 AI야. 이미지 속 물건이 무엇인지 식별하고, 이 물건을 어떻게 버려야 하는지(재활용 방법) 정확히 알려줘. 재질, 분류(예: 플라스틱, 캔류, 일반쓰레기 등), 그리고 버릴 때 주의사항을 친근한 구어체로 설명해줘. 중요: 답변은 음성으로 변환될 거니까 마크다운 형식이나 특수문자(#, *, -, 등)를 절대 사용하지 마.',
                'en': 'You are a recycling expert AI from the Ministry of Environment. Identify the object in the image and explain exactly how to dispose of it (recycling method). Describe the material, category (e.g., Plastic, Cans, General Waste), and any precautions for disposal in a friendly, conversational tone. Important: Your response will be converted to speech, so do not use any markdown formatting or special characters.',
                'ja': 'あなたは環境省所属のリサイクル分別専門家AIです。画像の中の物が何かを識別し、その物の捨て方（リサイクル方法）を正確に教えてください。材質、分類（例：プラスチック、缶類、一般ゴミなど）、そして捨てる際の注意事項を、親しみやすい話し言葉で説明してください。重要：回答は音声に変換されるため、マークダウン形式や特殊文字は絶対に使用しないでください。',
                'zh': '你是一名来自环境部的回收分类专家AI。请识别图像中的物品，并准确解释如何处理它（回收方法）。请用友好的对话方式说明其材质、分类（例如：塑料、罐头、一般垃圾等）以及处理时的注意事项。重要提示：你的回答将被转换为语音，因此请不要使用任何markdown格式或特殊字符。'
            };
            return prompts[lang] || prompts['ko'];
        },

        sendForInspection: async function(){
            $('#spinner').css('visibility','visible');
            $('#sendCamera, #sendUpload').prop('disabled', true);

            const formData = new FormData();
            let imageBlob = null;

            // 1. 이미지 데이터 준비
            if(this.currentMode === 'camera' && this.capturedBlob) {
                formData.append("attach", this.capturedBlob, "camera-capture.jpg");
                imageBlob = this.capturedBlob;
            } else if(this.currentMode === 'upload' && this.uploadedFile) {
                formData.append("attach", this.uploadedFile);
                imageBlob = this.uploadedFile;
            } else {
                alert("검사할 이미지를 준비해주세요.");
                $('#spinner').css('visibility','hidden');
                $('#sendCamera, #sendUpload').prop('disabled', false);
                return;
            }

            // 2. 프롬프트 및 언어 준비
            const question = this.getPromptByLanguage(this.currentLanguage);
            formData.append("question", question);
            formData.append('language', this.currentLanguage);

            try {
                // 3. AI 검사 요청
                const response = await fetch('/ai3/vehicle-inspection', {
                    method: "post",
                    headers: {
                        'Accept': 'application/json'
                    },
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`서버 오류: ${response.statusText}`);
                }

                // 4. JSON 응답 처리
                const answerJson = await response.json();
                console.log('서버 응답:', answerJson);

                if(!answerJson.text || !answerJson.audio) {
                    throw new Error("서버 응답 형식이 올바르지 않습니다. (text/audio 누락)");
                }

                // 5. 완성된 결과 HTML 생성
                let imageUrl = URL.createObjectURL(imageBlob);

                // 스타일 클래스 결정
                let alertClass = 'alert-info';
                const text = answerJson.text;
                if(text.includes('대포') || text.includes('위험') || text.includes('도난') || text.includes('수배')) {
                    alertClass = 'alert-danger';
                } else if(text.includes('주의') || text.includes('확인 필요') || text.includes('불일치')) {
                    alertClass = 'alert-warning';
                } else if(text.includes('정상') || text.includes('문제없음') || text.includes('일치')) {
                    alertClass = 'alert-success';
                }

                // HTML 이스케이프
                const div = document.createElement('div');
                div.textContent = answerJson.text;
                const escapedText = div.innerHTML;

                // 완성된 결과 HTML (한 번에 생성)
                let resultHtml =
                    '<div class="media border p-3 mb-3">' +
                    '<div class="media-body">' +
                    '<h6>AI 검사 결과 <small class="text-muted">' + new Date().toLocaleString() + '</small></h6>' +
                    '<img src="' + imageUrl + '" alt="검사 이미지" class="img-fluid rounded mb-2" style="max-width:200px; border:1px solid #ddd;" />' +
                    '<div class="inspection-result ' + alertClass + '">' +
                    '<pre>' + escapedText + '</pre>' +
                    '</div>' +
                    '</div>' +
                    '</div>';

                // 결과 컨테이너에 한 번에 추가
                $('#resultContainer').prepend(resultHtml);

                console.log('✅ 결과 표시 완료');
                console.log('텍스트 길이:', answerJson.text.length);

                // 8. 스피너 숨김 및 버튼 재활성화
                $('#spinner').css('visibility','hidden');
                if(this.currentMode === 'camera') $('#sendCamera').prop('disabled', false);
                if(this.currentMode === 'upload') $('#sendUpload').prop('disabled', false);

                // 9. 오디오 설정 및 재생
                const audioPlayer = document.getElementById("audioPlayer");
                audioPlayer.src = "data:audio/mp3;base64," + answerJson.audio;
                audioPlayer.play().catch(err => {
                    console.warn("오디오 자동재생이 브라우저에 의해 차단되었습니다:", err);
                });

            } catch(err) {
                console.error('검사 중 오류:', err);
                alert('검사 중 오류가 발생했습니다: ' + err.message);
                $('#spinner').css('visibility','hidden');
                $('#sendCamera, #sendUpload').prop('disabled', false);
            }
        },

        formatInspectionResult: function(content){
            let alertClass = 'alert-info';
            if(content.includes('대포') || content.includes('위험') || content.includes('도난') || content.includes('수배')) {
                alertClass = 'alert-danger';
            } else if(content.includes('주의') || content.includes('확인 필요') || content.includes('불일치')) {
                alertClass = 'alert-warning';
            } else if(content.includes('정상') || content.includes('문제없음') || content.includes('일치')) {
                alertClass = 'alert-success';
            }

            // HTML 특수문자 이스케이프 (순수 JavaScript 방식)
            const div = document.createElement('div');
            div.textContent = content;
            const escapedContent = div.innerHTML;

            console.log('원본 content:', content.substring(0, 100));
            console.log('이스케이프된 content:', escapedContent.substring(0, 100));

            return `<div class="inspection-result ${alertClass}">` +
                `<pre>${escapedContent}</pre>` +
                `</div>`;
        },

        makeResultUi: function(imageBlob){
            let uuid = "result-" + crypto.randomUUID();
            let imageUrl = URL.createObjectURL(imageBlob);

            let resultHtml =
                '<div class="media border p-3 mb-3">' +
                '<div class="media-body">' +
                '<h6>AI 검사 결과 <small class="text-muted">' + new Date().toLocaleString() + '</small></h6>' +
                '<img src="' + imageUrl + '" alt="검사 이미지" class="img-fluid rounded mb-2" style="max-width:200px; border:1px solid #ddd;" />' +
                '<div id="' + uuid + '">' +
                '<div class="spinner-border spinner-border-sm text-primary" role="status">' +
                '<span class="sr-only">답변 생성 중...</span>' +
                '</div>' +
                '<span class="text-muted"> AI가 분석 중입니다...</span>' +
                '</div>' +
                '</div>' +
                '</div>';

            $('#resultContainer').prepend(resultHtml);
            return uuid;
        }
    }

    $(function(){
        vehicleAi.init();
    });
</script>

<div class="col-sm-10">
    <h2> AI 재활용품 분류 시스템</h2>
    <p class="text-muted">이미지를 분석하여 올바른 재활용품 분리배출 방법을 텍스트와 음성으로 안내합니다.</p>

    <div class="row">
        <div class="col-md-7">
            <div class="language-selector">
                <label for="language">검사 언어 (Language)</label>
                <select id="language" class="form-control">
                    <option value="ko">한국어 (Korean)</option>
                    <option value="en">English</option>
                    <option value="ja">日本語 (Japanese)</option>
                    <option value="zh">中文 (Chinese)</option>
                </select>
            </div>

            <div class="tab-buttons">
                <button type="button" class="btn btn-primary" id="cameraTab"> 카메라 촬영</button>
                <button type="button" class="btn btn-outline-primary" id="uploadTab"> 파일 업로드</button>
            </div>

            <div id="uploadSection" style="display:none;">
                <div class="card mb-3">
                    <div class="card-body">
                        <div class="form-group">
                            <label for="attach">재활용품 이미지 선택</label>
                            <input id="attach" class="form-control-file" type="file" accept="image/*"/>
                        </div>
                        <div class="text-center mt-3">
                            <img id="uploadPreview" class="preview-image" style="display:none;" alt="업로드 미리보기"/>
                        </div>
                        <div class="text-center mt-3">
                            <button type="button" class="btn btn-danger btn-lg" id="sendUpload" disabled>
                                 업로드 검사 시작
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex align-items-center mb-2">
                <button class="btn btn-primary" disabled style="visibility:hidden;" id="spinnerBtn">
                    <span class="spinner-border spinner-border-sm" id="spinner"></span>
                    검사 중...
                </button>
                <audio id="audioPlayer" controls style="display:none;"></audio>
            </div>

            <h4>검사 결과</h4>
            <div id="resultContainer" class="border rounded p-3" style="min-height: 400px; max-height: 600px; overflow-y: auto; background-color: #f8f9fa;">
                <p class="text-muted text-center" style="padding-top: 150px;">검사 결과가 여기에 표시됩니다.</p>
            </div>
        </div>

        <div class="col-md-5">
            <div id="cameraSection">
                <div class="card">
                    <div class="card-header">실시간 카메라</div>
                    <div class="card-body p-1">
                        <div id="videoContainer">
                            <video id="video" autoplay playsinline></video>
                            <canvas id="canvas"></canvas>
                        </div>

                        <div class="camera-controls p-2">
                            <button type="button" class="btn btn-success" id="startCamera">카메라 시작</button>
                            <button type="button" class="btn btn-primary" id="captureBtn" style="display:none;"> 촬영</button>
                            <button type="button" class="btn btn-secondary" id="stopCamera" style="display:none;">정지</button>
                        </div>

                        <div class="text-center mt-2 p-2">
                            <h6 class="text-muted">촬영된 이미지</h6>
                            <img id="capturedImage" class="preview-image" style="display:none; border: 1px solid #ccc;" alt="촬영된 이미지"/>
                        </div>

                        <div class="text-center p-3">
                            <button type="button" class="btn btn-danger btn-lg" id="sendCamera" disabled>
                                 촬영본 검사 시작
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
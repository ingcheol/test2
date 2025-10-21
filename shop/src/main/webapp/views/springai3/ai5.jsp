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

  .language-selector {
    background: #28a745;
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
    color: white;
  }

  .upload-area {
    background: #f8f9fa;
    border: 2px dashed #28a745;
    border-radius: 10px;
    padding: 20px;
    text-align: center;
    margin-bottom: 15px;
    cursor: pointer;
    transition: all 0.3s;
  }

  .upload-area:hover {
    background: #e9ecef;
    border-color: #218838;
  }

  .upload-area.active {
    background: #d4edda;
    border-color: #155724;
  }

  .recommendation-section {
    background: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 15px;
    margin: 15px 0;
    border-radius: 5px;
  }

  .recommendation-section h5 {
    margin-bottom: 10px;
    color: #856404;
  }

  .recommendation-section p {
    margin: 5px 0;
    line-height: 1.6;
  }

  .recommendation-item {
    background: white;
    border-radius: 8px;
    padding: 10px;
    margin: 10px 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .recommendation-item h6 {
    color: #28a745;
    margin-bottom: 5px;
  }

  .location-info-section {
    background: #d1ecf1;
    border-left: 4px solid #0c5460;
    padding: 15px;
    margin: 15px 0;
    border-radius: 5px;
  }

  .location-info-section h5 {
    margin-bottom: 10px;
    color: #0c5460;
  }

  .location-info-section p {
    margin: 8px 0;
    line-height: 1.6;
  }

  .analyzing-badge {
    display: inline-block;
    background: #17a2b8;
    color: white;
    padding: 5px 10px;
    border-radius: 5px;
    font-size: 12px;
    margin: 5px 0;
  }
</style>

<script>
  let locationAI = {
    CapturedBlob: null,
    currentLanguage: 'ko',
    uploadedFile: null,

    init:function(){
      this.previewCamera('video');

      $('#send').click(()=>{
        this.captureFrame("video", (pngBlob) => {
          this.CapturedBlob = pngBlob;
          this.send(pngBlob, 'camera');
        });
      });

      // 파일 업로드 이벤트
      $('#imageUpload').change((e) => {
        const file = e.target.files[0];
        if (file && file.type.startsWith('image/')) {
          console.log('파일 선택됨:', file.name);
          this.uploadedFile = file;
          this.send(file, 'upload');
        } else {
          alert('이미지 파일만 업로드 가능합니다.');
        }
      });

      // 드래그 앤 드롭
      const uploadArea = document.getElementById('uploadArea');

      uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        e.stopPropagation();
        uploadArea.classList.add('active');
      });

      uploadArea.addEventListener('dragleave', (e) => {
        e.preventDefault();
        e.stopPropagation();
        uploadArea.classList.remove('active');
      });

      uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        e.stopPropagation();
        uploadArea.classList.remove('active');

        const file = e.dataTransfer.files[0];
        if (file && file.type.startsWith('image/')) {
          console.log('파일 드롭됨:', file.name);
          this.uploadedFile = file;
          this.send(file, 'upload');
        } else {
          alert('이미지 파일만 업로드 가능합니다.');
        }
      });

      uploadArea.addEventListener('click', () => {
        document.getElementById('imageUpload').click();
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
        'ko': '너는 세계적인 수준의 이미지 분석 전문가이자 위치 특정 전문가야. 이미지 속 장소를 정확히 식별하는 것이 최우선 목표야.\n\n🔍 분석 방법론:\n\n1단계 - 텍스트 완벽 추출:\n- 이미지의 모든 텍스트를 읽어라 (간판, 로고, 안내문, 메뉴, 표지판, 전시물 라벨, 건물명)\n- 영어, 한국어, 중국어, 일본어 등 모든 언어의 텍스트 인식\n- 부분적으로 가려진 텍스트도 추론해서 완성\n- 브랜드 로고나 상징 마크 식별\n\n2단계 - 건축/디자인 특징 분석:\n- 건축 양식과 시대 (고전, 현대, 포스트모던 등)\n- 파사드 디자인, 기둥 스타일, 창문 형태\n- 색상 팔레트와 재질 (돌, 유리, 금속 등)\n- 인테리어 디자인 요소 (조명, 가구, 바닥재)\n\n3단계 - 세계적 랜드마크 매칭:\n- 메트로폴리탄 미술관, 루브르, 대영박물관, 국립중앙박물관 등\n- 유명 레스토랑 체인 (맥도날드, 스타벅스, 현지 유명 식당)\n- 관광 명소 (에펠탑, 자유의 여신상, 타지마할 등)\n- 즉시 인식 가능한 아이코닉한 장소들\n\n4단계 - 지리적 단서 수집:\n- 도로 표지판의 언어와 형식\n- 차량 번호판 스타일\n- 주변 건물 스타일과 도시 계획\n- 기후와 식생 특징\n\n5단계 - 교차 검증:\n- 여러 단서를 종합해서 최종 결론\n- 모순되는 정보가 있다면 언급\n\n📋 필수 출력 형식:\n\n[장소명] (예: 메트로폴리탄 미술관, 스타벅스 강남점, 또는 "정확한 특정 불가")\n[위치] (상세 주소 또는 "서울 강남구" 같은 지역명)\n[연락처] (전화번호, 없으면 생략)\n[신뢰도] 높음/중간/낮음\n\n장소 설명:\n- 장소 유형 명시 (박물관/미술관/식당/카페/관광지/거리/건물)\n- 특징과 역사적 배경\n- 방문 가치와 특별한 점\n\n추천:\n[추천1] 구체적 항목명: 상세 설명\n[추천2] 구체적 항목명: 상세 설명  \n[추천3] 구체적 항목명: 상세 설명\n\n⚠️ 신뢰도가 낮거나 특정 불가시:\n"현재 이미지만으로는 정확한 장소를 특정하기 어렵습니다. 이유: [구체적인 이유]. 다음과 같은 추가 사진이 있으면 정확히 알려드릴 수 있습니다: (1) 건물 전체 외관, (2) 간판이나 입구 근처, (3) 주변 거리 풍경"\n\n중요: 마크다운 없이 자연스러운 말투로 설명. 추측이 아닌 확실한 정보만 제공.',

        'en': 'You are a professional image analyst and location identification expert. Analyze the image very precisely to identify the specific location.\n\nAnalysis Priority:\n1. Text Information: Read all text including signs, logos, information boards, menus, exhibits, building names.\n2. Visual Features: Carefully analyze architectural style, logo design, interior style, color schemes, decorative elements.\n3. Famous Landmarks: For world-famous buildings, museums, or galleries, you should be able to identify them immediately from exterior or interior.\n4. Location Clues: Estimate country/city from surroundings, road signs, license plates, language use.\n\nAnswer in this format:\n\n[Location Name] (specific name if found, otherwise "Cannot specify")\n[Address] (address or area)\n[Contact] (phone number, omit if unavailable)\n[Confidence] (High/Medium/Low - how certain you are)\n\nIf location identified:\n- Place type (museum/gallery/restaurant/cafe/attraction)\n- Description of the place\n- 3 recommendations: [Recommendation1], [Recommendation2], [Recommendation3]\n\nIf confidence is low: "Cannot accurately identify the location from current image features. More accurate identification possible with: full building exterior, clear signage/logos, surrounding street views"\n\nImportant: No markdown or special characters, natural speaking tone.',

        'ja': 'あなたはプロの画像分析家であり、位置特定の専門家です。画像を非常に精密に分析して、具体的な場所を特定してください。\n\n分析の優先順位:\n1. テキスト情報: 看板、ロゴ、案内板、メニュー、展示物の説明、建物名など、すべてのテキストを読み取り正確に把握してください。\n2. 視覚的特徴: 建築様式、ロゴデザイン、インテリアスタイル、色の組み合わせ、装飾要素を詳しく分析してください。\n3. 有名なランドマーク: 世界的に有名な建物や博物館、美術館の場合、外観や内部だけで即座に特定できるはずです。\n4. 位置の手がかり: 周辺環境、道路標識、ナンバープレート、言語使用などから国/都市を推定してください。\n\n必ず次の形式で回答してください:\n\n[場所名] (正確な名前を見つけた場合は具体的に、見つからない場合は「特定不可」)\n[住所] (住所または地域)\n[連絡先] (電話番号、見つからない場合は省略)\n[信頼度] (高/中/低 - どれくらい確実か)\n\n場所を特定した場合:\n- 場所のタイプ (博物館/美術館/レストラン/カフェ/観光地など)\n- その場所の特徴の説明\n- 推奨項目3つ: [推薦1]、[推薦2]、[推薦3]の形式\n\n信頼度が低い場合: \"現在の画像の特徴だけでは正確な場所の特定が困難です。次の情報があればより正確に分かります: 建物の外観全体、看板やロゴが明確に見える写真、周辺の街の風景など\"\n\n重要: マークダウンや特殊文字を使用せず、自然に説明してください。',

        'zh': '你是专业的图像分析师和位置识别专家。请非常精确地分析图像以识别具体位置。\n\n分析优先级:\n1. 文本信息: 阅读所有文本，包括招牌、标志、信息板、菜单、展品说明、建筑名称等。\n2. 视觉特征: 仔细分析建筑风格、标志设计、室内风格、色彩组合、装饰元素。\n3. 著名地标: 对于世界著名的建筑、博物馆或美术馆，应该能够从外观或内部立即识别。\n4. 位置线索: 从周围环境、路标、车牌、语言使用等估计国家/城市。\n\n按以下格式回答:\n\n[地点名称] (如果找到具体名称则详细说明，否则写"无法确定")\n[地址] (地址或区域)\n[联系方式] (电话号码，如不可用则省略)\n[可信度] (高/中/低 - 有多确定)\n\n如果识别出位置:\n- 场所类型 (博物馆/美术馆/餐厅/咖啡馆/景点)\n- 场所特征描述\n- 3个推荐: [推荐1]、[推荐2]、[推荐3]\n\n如果可信度低: "仅凭当前图像特征无法准确识别位置。以下信息可帮助更准确识别: 建筑外观全景、清晰的招牌/标志、周围街景等"\n\n重要提示: 不使用markdown或特殊字符，用自然语气解释。'
      };
      return prompts[lang] || prompts['ko'];
    },

    send: async function(imageBlob, source){
      $('#spinner').css('visibility','visible');

      const imageUrl = URL.createObjectURL(imageBlob);

      let sourceLabel = source === 'camera' ? '카메라 캡처' : '업로드된 이미지';
      let captureForm = `
              <div class="media border p-3 mb-2">
                <div class="media-body">
                  <small class="text-muted">${sourceLabel}</small>
                  <img src="`+imageUrl+`" alt="분석 이미지" class="img-fluid" style="max-width:400px; border:1px solid #ddd; border-radius:5px;" />
                  <div class="mt-2">
                    <span class="analyzing-badge">🔍 AI 이미지 분석 중...</span>
                  </div>
                </div>
              </div>
            `;
      $('#result').prepend(captureForm);

      const question = this.getPromptByLanguage(this.currentLanguage);

      const formData = new FormData();
      formData.append("question", question);
      formData.append('attach', imageBlob, 'image.png');
      formData.append('language', this.currentLanguage);

      try {
        const response = await fetch('/ai3/image-analysis2', {
          method: "post",
          headers: {
            'Accept': 'application/json'
          },
          body: formData
        });

        if (!response.ok) {
          throw new Error('서버 응답 오류: ' + response.status);
        }

        const answerJson = await response.json();
        console.log('서버 응답:', answerJson);

        const audioPlayer = document.getElementById("audioPlayer");
        audioPlayer.src = "data:audio/mp3;base64," + answerJson.audio;

        audioPlayer.addEventListener("play", () => {
          let uuid = this.makeUi("result");
          let answer = answerJson.text;
          $('#'+uuid).html(answer);

          // 장소 정보 및 추천 항목 파싱
          this.parseAndDisplayRecommendations(answer, uuid);
        }, { once: true });

        audioPlayer.addEventListener("ended", () => {
          $('#spinner').css('visibility','hidden');
          console.log("분석 종료");
          URL.revokeObjectURL(imageUrl);
        }, { once: true });

        audioPlayer.play();

      } catch(error) {
        console.error('위치 분석 오류:', error);
        $('#spinner').css('visibility','hidden');

        const errorMessages = {
          'ko': '위치 분석 중 오류가 발생했습니다: ' + error.message,
          'en': 'An error occurred during location analysis: ' + error.message,
          'ja': '位置分析中にエラーが発生しました: ' + error.message,
          'zh': '位置分析过程中发生错误: ' + error.message
        };
        alert(errorMessages[this.currentLanguage] || errorMessages['ko']);
        URL.revokeObjectURL(imageUrl);
      }
    },

    parseAndDisplayRecommendations: function(text, parentUuid) {
      // [장소명], [위치], [연락처], [신뢰도] 정보 추출
      const locationInfo = {
        name: null,
        address: null,
        contact: null,
        confidence: null
      };

      const locationPatterns = {
        ko: {
          name: /\[장소명\][:\s]*([^\n\[]+)/i,
          address: /\[위치\][:\s]*([^\n\[]+)/i,
          contact: /\[연락처\][:\s]*([^\n\[]+)/i,
          confidence: /\[신뢰도\][:\s]*([^\n\[]+)/i
        },
        en: {
          name: /\[Location Name\][:\s]*([^\n\[]+)/i,
          address: /\[Address\][:\s]*([^\n\[]+)/i,
          contact: /\[Contact\][:\s]*([^\n\[]+)/i,
          confidence: /\[Confidence\][:\s]*([^\n\[]+)/i
        },
        ja: {
          name: /\[場所名\][:\s]*([^\n\[]+)/i,
          address: /\[住所\][:\s]*([^\n\[]+)/i,
          contact: /\[連絡先\][:\s]*([^\n\[]+)/i,
          confidence: /\[信頼度\][:\s]*([^\n\[]+)/i
        },
        zh: {
          name: /\[地点名称\][:\s]*([^\n\[]+)/i,
          address: /\[地址\][:\s]*([^\n\[]+)/i,
          contact: /\[联系方式\][:\s]*([^\n\[]+)/i,
          confidence: /\[可信度\][:\s]*([^\n\[]+)/i
        }
      };

      // 장소 정보 파싱
      Object.keys(locationPatterns).forEach(lang => {
        if (!locationInfo.name) {
          const nameMatch = text.match(locationPatterns[lang].name);
          if (nameMatch) locationInfo.name = nameMatch[1].trim();
        }
        if (!locationInfo.address) {
          const addressMatch = text.match(locationPatterns[lang].address);
          if (addressMatch) locationInfo.address = addressMatch[1].trim();
        }
        if (!locationInfo.contact) {
          const contactMatch = text.match(locationPatterns[lang].contact);
          if (contactMatch) locationInfo.contact = contactMatch[1].trim();
        }
        if (!locationInfo.confidence) {
          const confidenceMatch = text.match(locationPatterns[lang].confidence);
          if (confidenceMatch) locationInfo.confidence = confidenceMatch[1].trim();
        }
      });

      console.log('장소 정보:', locationInfo);

      // [추천1], [추천2], [추천3] 패턴 찾기
      const patterns = [
        /\[추천(\d+)\][:\s]*([^\n\[]+)/g,
        /\[Recommendation(\d+)\][:\s]*([^\n\[]+)/gi,
        /\[推薦(\d+)\][:\s]*([^\n\[]+)/g,
        /\[推荐(\d+)\][:\s]*([^\n\[]+)/g
      ];

      let recommendations = [];
      for (let pattern of patterns) {
        let match;
        while ((match = pattern.exec(text)) !== null) {
          recommendations.push({
            number: match[1],
            content: match[2].trim()
          });
        }
      }

      console.log('찾은 추천:', recommendations);

      // 장소 정보 섹션 생성
      if (locationInfo.name || locationInfo.address || locationInfo.contact) {
        let locInfoId = "loc-info-" + crypto.randomUUID();
        let confidenceBadge = '';

        if (locationInfo.confidence) {
          let badgeColor = '#6c757d';
          if (locationInfo.confidence.includes('높음') || locationInfo.confidence.includes('High') || locationInfo.confidence.includes('高')) {
            badgeColor = '#28a745';
          } else if (locationInfo.confidence.includes('중간') || locationInfo.confidence.includes('Medium') || locationInfo.confidence.includes('中')) {
            badgeColor = '#ffc107';
          } else if (locationInfo.confidence.includes('낮음') || locationInfo.confidence.includes('Low') || locationInfo.confidence.includes('低')) {
            badgeColor = '#dc3545';
          }
          confidenceBadge = `<span style="display:inline-block; background:${badgeColor}; color:white; padding:3px 8px; border-radius:3px; font-size:12px; margin-left:10px;">신뢰도: ${locationInfo.confidence}</span>`;
        }

        let locInfoHtml = `
                    <div class="location-info-section" id="${locInfoId}">
                        <h5>📍 장소 정보 ${confidenceBadge}</h5>
                `;

        if (locationInfo.name && !locationInfo.name.includes('특정 불가') && !locationInfo.name.includes('Cannot specify')) {
          locInfoHtml += `<p><strong>📌 장소명:</strong> ${locationInfo.name}</p>`;
        }
        if (locationInfo.address) {
          locInfoHtml += `<p><strong>🗺️ 주소:</strong> ${locationInfo.address}</p>`;
        }
        if (locationInfo.contact) {
          locInfoHtml += `<p><strong>📞 연락처:</strong> ${locationInfo.contact}</p>`;
        }

        locInfoHtml += `</div>`;
        $('#'+parentUuid).after(locInfoHtml);
      }

      // 추천 섹션 생성
      if (recommendations.length > 0) {
        let recSectionId = "rec-section-" + crypto.randomUUID();
        let recSection = `
                    <div class="recommendation-section" id="${recSectionId}">
                        <h5>🎯 추천 항목</h5>
                        <div id="rec-items-${recSectionId}"></div>
                    </div>
                `;
        $('#'+parentUuid).after(recSection);

        // 각 추천 항목 표시
        let recHtml = '';
        recommendations.forEach((rec) => {
          recHtml += `
                        <div class="recommendation-item">
                            <h6>✨ 추천 ${rec.number}</h6>
                            <p>${rec.content}</p>
                        </div>
                    `;
        });

        $('#rec-items-'+recSectionId).html(recHtml);
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
    locationAI.init();
  });
</script>

<div class="col-sm-10">
  <h2>위치 인식 AI</h2>
  <p class="text-muted">사진 속 장소를 정확하게 분석하고 상세 정보를 제공합니다</p>

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

      <!-- 이미지 업로드 영역 -->
      <div id="uploadArea" class="upload-area">
        <i class="bi bi-cloud-upload" style="font-size: 2rem; color: #28a745;"></i>
        <p class="mb-1"><strong>이미지를 드래그하거나 클릭하여 업로드</strong></p>
        <p class="text-muted small">JPG, PNG 파일 지원 | 건물 외관, 간판, 내부 사진 권장</p>
        <input type="file" id="imageUpload" accept="image/*" style="display:none;">
      </div>

      <div class="row mb-3">
        <div class="col-sm-12">
          <audio id="audioPlayer" controls style="display:none;"></audio>
        </div>
      </div>

      <div class="row mb-3">
        <div class="col-sm-3">
          <button type="button" class="btn btn-success btn-block" id="send">
            <i class="bi bi-camera"></i> 카메라 캡처 분석
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
        <div class="text-center text-muted p-5">
          <i class="bi bi-camera" style="font-size: 3rem;"></i>
          <p class="mt-3">사진을 업로드하거나 카메라로 촬영하여 분석을 시작하세요</p>
        </div>
      </div>
    </div>

    <div class="col-sm-4">
      <div class="card">
        <h5 class="mb-0">카메라</h5>
        <div class="card-body p-0">
          <video id="video" class="img-fluid" style="width:100%; height:auto;" autoplay></video>
        </div>
      </div>

      <div class="card mt-3">
        <div class="card-body">
          <h6>분석 팁</h6>
          <ul class="small">
            <li>건물 외관이나 간판이 명확한 사진이 좋아요</li>
            <li>텍스트나 로고가 잘 보이게 촬영하세요</li>
            <li>여러 각도에서 촬영하면 더 정확해요</li>
            <li>흐릿하지 않은 선명한 사진을 사용하세요</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    let food = {
        init: function(){
            $('#send').click(() => {
                this.send();
            });
            $('#spinner').css('visibility', 'hidden');
        },

        send: async function(){
            $('#spinner').css('visibility', 'visible');

            let country = $('#question').val().trim();
            if (!country) {
                alert('가고 싶은 나라를 입력해주세요.');
                $('#spinner').css('visibility', 'hidden');
                return;
            }

            $('#result').empty();
            $('#question').val('');

            try {
                await this.getFoodRecommendation(country);
            } catch (error) {
                console.error('Error:', error);
                this.showError('처리 중 오류가 발생했습니다: ' + error.message);
            } finally {
                $('#spinner').css('visibility', 'hidden');
            }
        },

        getFoodRecommendation: async function(country){
            // 음식 추천 카드 먼저 표시
            let recommendHtml =
                '<div class="card mb-3 border-info">' +
                '<div class="card-header bg-info text-white">' +
                '<h6 class="mb-0">' + country + ' 현지 음식 추천</h6>' +
                '</div>' +
                '<div class="card-body">' +
                '<div id="foodList">음식을 추천 중입니다...</div>' +
                '</div>' +
                '</div>';
            $('#result').append(recommendHtml);

            let recommendPrompt =
                '당신은 ' + country + ' 현지 음식을 전문적으로 소개하는 친절한 여행 가이드입니다.\n' +
                '처음 ' + country + '을(를) 방문하는 여행객을 위해, 대표적인 현지 음식 3가지를 추천해주세요.\n\n' +
                '## 응답 규칙:\n' +
                '1. 반드시 3가지만 추천해야 합니다.\n' +
                '2. **아래의 응답 형식을 100% 정확하게 지켜야 합니다.** (다른 말은 절대 덧붙이지 마세요)\n' +
                '   1. [음식 이름] - [설명]\n\n' +
                '   2. [음식 이름] - [설명]\n\n' +
                '   3. [음식 이름] - [설명]\n\n' +
                '3. [설명] 부분은 **하나의 긴 문단**으로 작성해야 하며, 다음 4가지 내용을 **모두** 자연스럽게 녹여내야 합니다.\n' +
                '   - (1) 맛과 특징: 음식의 맛, 향, 식감 등 (예: "매콤하면서도 고소한", "부드러운 식감")\n' +
                '   - (2) 주요 재료: 2가지 이상 (예: "돼지고기와 각종 채소")\n' +
                '   - (3) 먹는 시기/방법: (예: "아침 식사로", "해장용으로", "맥주 안주로")\n' +
                '   - (4) 여행객을 위한 팁: (예: "함께 나오는 소스에 찍어 드세요", "주문 시 \'고수 빼주세요\'라고 말하세요")\n' +
                '4. 설명은 각 음식마다 **최소 70자 이상**으로, 여행객이 정말 도움이 될 만큼 자세하게 작성해주세요.\n\n' +
                '## 응답 예시 (이것은 "가상" 예시입니다. 실제 ' + country + ' 음식으로 작성해야 합니다):\n' +
                '1. 별빛 꼬치 - 숯불 향이 가득 배인 부드러운 닭고기와 달콤한 파인애플을 번갈아 낀 꼬치 요리예요. 닭고기와 파인애플에 특제 땅콩 소스를 발라 구워내어 고소함과 상큼함이 폭발하죠. 주로 저녁 시장에서 길거리 간식으로 맥주와 함께 즐겨 먹습니다. 팁: 가게마다 소스 맛이 다르니, 땅콩 소스를 듬뿍 발라주는 곳을 고르는 게 좋아요!\n' +
                '2. 안개 수프 - 푹 고아낸 소고기 육수에 안개꽃 버섯과 얇은 쌀국수를 넣어 끓인 맑은 수프입니다. 소고기 육수와 안개꽃 버섯이 주재료이며, 맛이 순하고 담백해서 속이 편안해지는 느낌이에요. 비 오는 날 아침이나 해장용으로 현지인들이 즐겨 찾습니다. 팁: 함께 나오는 라임 한 조각을 꾹 짜 넣으면 풍미가 훨씬 살아나요!\n' +
                '3. 용암 볶음밥 - 붉은 용암 소스로 밥과 해산물을 볶아낸 매콤한 볶음밥입니다. 새우, 오징어 등 해산물과 붉은 고추 소스가 들어가며, 치즈를 넉넉히 올려 마무리하는 것이 특징이죠. 매운맛이 당기는 날 점심 식사로 인기가 많습니다. 팁: 너무 맵다면 계란 후라이(카이 다오)를 추가해서 밥과 함께 비벼 먹으면 훨씬 부드러워져요.\n\n' +
                '이제 ' + country + '의 음식을 위 규칙과 형식에 맞춰 추천해주세요:';

            try {
                const response = await fetch('/ai3/chat-text', {
                    method: 'post',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: new URLSearchParams({ question: recommendPrompt })
                });

                const data = await response.json();
                const foodList = data.text || data.content || JSON.stringify(data);

                $('#foodList').html('<pre style="white-space: pre-wrap;">' + foodList + '</pre>');

                // 모든 음식 추출
                let allFoods = this.extractAllFoods(foodList);

                // 각 음식에 대해 이미지 생성
                for (let i = 0; i < allFoods.length; i++) {
                    await this.generateFoodImage(allFoods[i], country, i + 1);
                }

            } catch (error) {
                console.error('음식 추천 에러:', error);
                $('#foodList').html('<span class="text-danger">음식 추천에 실패했습니다.</span>');
            }
        },

        extractAllFoods: function(text){
            // "1. 음식이름", "2. 음식이름", "3. 음식이름" 형식에서 모든 음식 이름 추출
            let foods = [];
            let lines = text.split('\n');

            for (let line of lines) {
                // 숫자로 시작하는 줄 찾기 (1., 2., 3. 또는 1), 2), 3))
                if (line.match(/^[1-3]\.|^[1-3]\)/)) {
                    // 숫자, 점, 괄호, 하이픈 제거하여 음식 이름만 추출
                    let foodName = line.replace(/^[1-3][\.\)]\s*/, '')
                        .replace(/\s*-.*$/, '')
                        .trim();
                    if (foodName.length > 0) {
                        foods.push(foodName);
                    }
                }
            }

            // 3개 미만이면 빈 배열 반환
            if (foods.length < 3) {
                console.warn('음식 추출 실패, 추출된 음식:', foods);
                // 강제로 3개 추출 시도
                if (foods.length === 0) {
                    return ['음식1', '음식2', '음식3'];
                }
            }

            return foods;
        },

        generateFoodImage: async function(foodName, country, index){
            let selectedHtml =
                '<div class="card mb-3 border-success" id="food-card-' + index + '">' +
                '<div class="card-header bg-success text-white">' +
                '<h6 class="mb-0">' + index + '. ' + foodName + '</h6>' +
                '</div>' +
                '<div class="card-body text-center">' +
                '<p>이미지를 생성하는 중...</p>' +
                '<div class="spinner-border text-success" role="status"></div>' +
                '</div>' +
                '</div>';
            $('#result').append(selectedHtml);

            // 이미지 생성 프롬프트 (영어로)
            let imagePrompt =
                'Professional food photography of ' + foodName +
                ' from ' + country +
                ', beautifully plated, high quality, appetizing, vibrant colors, traditional presentation';

            try {
                const response = await fetch('/ai3/image-generate', {
                    method: 'post',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'text/plain'
                    },
                    body: new URLSearchParams({ question: imagePrompt })
                });

                const b64Json = await response.text();

                if (b64Json.includes("Error")) {
                    $('#food-card-' + index + ' .card-body').html(
                        '<p class="text-danger">이미지 생성 실패</p>'
                    );
                    return;
                }

                // 이미지 표시
                const base64Src = "data:image/png;base64," + b64Json;

                let imageHtml =
                    '<div class="card mb-3 border-warning" id="food-card-' + index + '">' +
                    '<div class="card-header bg-warning text-dark">' +
                    '<h6 class="mb-0">' + index + '. ' + foodName + '</h6>' +
                    '</div>' +
                    '<div class="card-body text-center">' +
                    '<img src="' + base64Src + '" class="img-fluid rounded" style="max-width: 600px;" alt="' + foodName + '" />' +
                    '</div>' +
                    '</div>';

                $('#food-card-' + index).replaceWith(imageHtml);

            } catch (error) {
                console.error('이미지 생성 에러:', error);
                $('#food-card-' + index + ' .card-body').html(
                    '<p class="text-danger">이미지 생성에 실패했습니다.</p>'
                );
            }
        },

        showError: function(message){
            let errorHtml =
                '<div class="alert alert-danger" role="alert">' +
                '<strong>오류!</strong> ' + message +
                '</div>';
            $('#result').append(errorHtml);
        }
    };

    $(()=>{
        food.init();
    });
</script>

<div class="col-sm-10">
  <h2>현지 음식 추천 및 이미지 생성</h2>
  <p class="text-muted">가고 싶은 나라를 입력하면 AI가 현지 음식 3가지를 추천하고, 각각의 이미지를 생성합니다.</p>

  <div class="row mb-4">
    <div class="col-sm-8">
      <input type="text" id="question" class="form-control" placeholder="예: 일본, 이탈리아, 태국 등" />
    </div>
    <div class="col-sm-2">
      <button type="button" class="btn btn-primary btn-block" id="send">
        <i class="fas fa-search"></i> 추천받기
      </button>
    </div>
    <div class="col-sm-2 text-center">
      <span class="spinner-border text-primary" id="spinner" role="status"></span>
    </div>
  </div>

  <div id="result" class="p-3 my-3 border rounded bg-light" style="min-height: 400px;">
    <div class="text-center text-muted mt-5">
      <i class="fas fa-utensils fa-3x mb-3"></i>
      <p>여행지를 입력하고 추천받기 버튼을 눌러주세요!</p>
    </div>
  </div>
</div>


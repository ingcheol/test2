package edu.sm.app.springai.service1;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class AiServiceFewShotPrompt {
    private ChatClient chatClient;

    public AiServiceFewShotPrompt(ChatClient.Builder chatClientBuilder) {
        chatClient = chatClientBuilder.build();
    }

    public String fewShotPrompt(String order) {
        String strPrompt = """
        고객 주문을 유효한 JSON 형식으로 바꿔주세요.
        김밥집 메뉴를 분석하여 각 메뉴의 이름, 가격, 이미지 URL, 수량을 포함해주세요.
        
        아래 규칙을 반드시 지켜주세요:
        1. 추가 설명이나 주석을 포함하지 마세요.
        2. 응답은 ```json 같은 마크다운 형식 없이, 순수한 JSON 문자열로만 반환해야 합니다
        3. items 배열 형태로 반환하세요
        4. 가격은 원 단위로 숫자만 입력하세요
        5. 이미지 경로는 /image/ 폴더 아래에 있는 메뉴 이미지를 사용하세요
           - 김밥 메뉴: /image/kimbap.png
           - 참치김밥: /image/tuna_kimbap.jpg
           - 치즈김밥: /image/cheese_kimbap.jpg
           - 김치김밥: /image/kimchi_kimbap.jpg
           - 돈까스: /image/donkatsu.jpg
           - 라면: /image/ramen.jpg
           - 기본 메뉴 이미지가 없으면: /image/default_menu.jpg
        
        예시1:
        참치김밥 2줄이랑 치즈김밥 1줄 주세요
        JSON 응답:
        {
          "items": [
            {
              "name": "참치김밥",
              "price": 3500,
              "quantity": 2,
              "image": "/image/tuna_kimbap.jpg"
            },
            {
              "name": "치즈김밥",
              "price": 3000,
              "quantity": 1,
              "image": "/image/cheese_kimbap.jpg"
            }
          ],
          "totalPrice": 10000
        }
        
        예시2:
        김치김밥 하나랑 돈까스 하나요
        JSON 응답:
        {
          "items": [
            {
              "name": "김치김밥",
              "price": 3000,
              "quantity": 1,
              "image": "/image/kimchi_kimbap.jpg"
            },
            {
              "name": "돈까스",
              "price": 7000,
              "quantity": 1,
              "image": "/image/donkatsu.jpg"
            }
          ],
          "totalPrice": 10000
        }
        
        고객 주문: %s""".formatted(order);

        Prompt prompt = Prompt.builder()
                .content(strPrompt)
                .build();

        String kimbapOrderJson = chatClient.prompt(prompt)
                .options(ChatOptions.builder()
                        .build())
                .call()
                .content();

        return kimbapOrderJson;
    }
}
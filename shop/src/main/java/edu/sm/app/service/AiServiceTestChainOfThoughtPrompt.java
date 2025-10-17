package edu.sm.app.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

@Service
@Slf4j
public class AiServiceTestChainOfThoughtPrompt {
    // ##### 필드 #####
    private ChatClient chatClient;

    // ##### 생성자 #####
    public AiServiceTestChainOfThoughtPrompt(ChatClient.Builder chatClientBuilder) {
        chatClient = chatClientBuilder.build();
    }

    // ##### 메소드 #####
    public Flux<String> chainOfThought(String question) {
        Flux<String> answer = chatClient.prompt()
                .user("""
            %s
            당신은 여행 경로 최적화 전문가입니다.
                    주어진 여행지들을 방문하는 최단 경로를 추천해주세요.
                    한 걸음씩 논리적으로 분석하여 답변하세요.
            
                    [분석 단계]
                    1. 출발지와 목적지들의 위치를 파악합니다.
                    2. 각 지점 간의 거리를 고려합니다.
                    3. 이동 순서를 최적화합니다.
                    4. 최종 추천 경로를 제시합니다.
            
                    [예시]
                    질문: 서울에서 출발하여 부산, 대구, 광주를 모두 방문하고 서울로 돌아오는 최단 경로를 알려주세요.
            
                    답변:\s
                    1단계: 위치 분석
                    - 서울(출발지): 한국 북부
                    - 부산: 한국 남동부 (서울에서 약 325km)
                    - 대구: 한국 남동부 중간 (서울에서 약 237km, 부산에서 약 88km)
                    - 광주: 한국 남서부 (서울에서 약 268km)
            
                    2단계: 거리 기반 분석
                    - 서울 → 대구: 237km
                    - 대구 → 부산: 88km
                    - 부산 → 광주: 298km (우회)
                    - 광주 → 서울: 268km
            
                    3단계: 경로 최적화
                    지리적으로 "서울 → 대구 → 부산"은 동쪽으로 이동하는 자연스러운 경로입니다.
                    그 다음 서쪽의 광주로 이동하고 서울로 돌아오는 것이 효율적입니다.
            
                    4단계: 최종 추천 경로
                    **서울 → 대구 → 부산 → 광주 → 서울**
                    - 총 거리: 약 891km
                    - 이유: 동쪽 방향으로 이동 후 서쪽으로 돌아오는 경로로,\s
                      불필요한 왕복이나 교차 이동을 최소화합니다.
            
                    대안 경로: 서울 → 광주 → 부산 → 대구 → 서울 (약 918km)
                    추천 경로가 약 27km 더 짧습니다.
            """.formatted(question))
                .stream()
                .content();
        return answer;
    }
}
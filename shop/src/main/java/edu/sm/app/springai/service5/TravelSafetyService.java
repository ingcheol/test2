package edu.sm.app.springai.service5;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TravelSafetyService {

  // ##### 필드 #####
  private ChatClient chatClient;

  @Autowired
  private TravelSafetyTools travelSafetyTools;

  // ##### 생성자 #####
  public TravelSafetyService(ChatModel chatModel) {
    this.chatClient = ChatClient.builder(chatModel).build();
  }

  // ##### LLM과 대화하는 메소드 #####
  public String chat(String question) {
    String answer = chatClient.prompt()
        .system("""
                당신은 여행 안전 전문 상담사입니다.
                사용자가 국가명을 물어보면 다음 정보를 제공하세요:

                1. 외교부 여행경보 단계 (1~4단계)
                   - 여러 지역에 다른 경보 단계가 있다면 모두 표시하세요
                   - 예: 일본은 대부분 1단계이지만 후쿠시마 일부만 3단계
                   - 예: 태국은 지역별로 1단계, 2단계, 3단계가 혼재

                2. 특별여행주의보 발령 여부

                3. 최근 안전공지 및 뉴스

                **중요**:\s
                - 지역별로 경보 단계가 다른 경우 반드시 구분하여 표시하세요
                - "일부 지역"이라는 표현을 명확히 하세요
                - 전체 국가가 위험한 것처럼 오해하지 않도록 주의하세요

                정보를 보기 쉽게 정리하여 제공하고,
                여행자가 주의해야 할 사항을 친절하게 안내하세요.

                국가명이 불명확한 경우 명확히 물어보세요.
            """)
        .user(question)
        .tools(travelSafetyTools)
        .call()
        .content();

    return answer;
  }
}

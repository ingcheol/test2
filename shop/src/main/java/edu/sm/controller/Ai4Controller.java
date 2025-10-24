package edu.sm.controller;

import edu.sm.app.springai.service4.AiChatService;
import edu.sm.app.springai.service4.ETLService;
import edu.sm.app.springai.service5.TravelSafetyService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/ai4")
@Slf4j
@RequiredArgsConstructor
public class Ai4Controller {

  final private AiChatService aiChatService;
  final private ETLService etlService;
  final private ChatClient.Builder chatClientBuilder;
  final private ChatMemory chatMemory;
  final private VectorStore vectorStore;
  final private TravelSafetyService travelSafetyService;

  @PostMapping(value = "/chat-with-tools", produces = MediaType.TEXT_PLAIN_VALUE)
  public String chatWithTools(@RequestParam String question,
                              HttpSession session) {
    log.info("=== Tool Chat 요청 ===");
    log.info("질문: {}", question);

    try {
      // VectorDB 검색 조건 (type 필터 없이 전체 검색)
      SearchRequest searchRequest = SearchRequest.builder()
          .query(question)
          .similarityThreshold(0.3)
          .topK(10)
          .build();

      // QuestionAnswerAdvisor 생성
      QuestionAnswerAdvisor questionAnswerAdvisor = QuestionAnswerAdvisor.builder(vectorStore)
          .searchRequest(searchRequest)
          .build();

      // ChatClient 생성
      ChatClient chatClient = chatClientBuilder
          .defaultAdvisors(
              PromptChatMemoryAdvisor.builder(chatMemory).build(),
              questionAnswerAdvisor
          )
          .build();

      String answer = chatClient.prompt()
          .user(question)
          .toolNames("getWeather", "recommendTourist", "recommendRestaurant")
          .advisors(advisorSpec -> advisorSpec.param(
              ChatMemory.CONVERSATION_ID, session.getId()
          ))
          .call()
          .content();

      log.info("응답 완료: {} 자", answer.length());
      return answer;

    } catch (Exception e) {
      log.error("Tool calling 실패", e);
      return "오류가 발생했습니다: " + e.getMessage();
    }
  }

  @RequestMapping(value = "/travel-safety-tools")
  public String travelSafetyTools(@RequestParam("question") String question) {
    String answer = travelSafetyService.chat(question);
    return answer;
  }

  @RequestMapping(value = "/txt-pdf-docx-etl")
  public String txtPdfDocxEtl(
      @RequestParam("type") String type,
      @RequestParam("attach") MultipartFile attach) throws Exception {
    String result = etlService.etlFromFile(type, attach);
    return result;
  }

  @RequestMapping(value = "/rag-clear")
  public String ragClear() {
    etlService.clearVectorStore();
    return "벡터 저장소의 데이터를 모두 삭제했습니다.";
  }

  @RequestMapping(value = "/rag-chat", produces = MediaType.TEXT_PLAIN_VALUE)
  public String ragChat(
      @RequestParam("question") String question,
      @RequestParam("type") String type) {
    String answer = etlService.ragChat(question, type);
    return answer;
  }

  @RequestMapping(value = "/chat")
  public Flux<String> inMemoryChatMemory(
      @RequestParam("question") String question,
      HttpSession session) {
    Flux<String> answer = aiChatService.chat(question, session.getId());
    return answer;
  }
}

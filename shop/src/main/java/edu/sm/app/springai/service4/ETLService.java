package edu.sm.app.springai.service4;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.SimpleLoggerAdvisor;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.document.Document;
import org.springframework.ai.document.DocumentReader;
import org.springframework.ai.reader.TextReader;
import org.springframework.ai.reader.pdf.PagePdfDocumentReader;
import org.springframework.ai.reader.tika.TikaDocumentReader;
import org.springframework.ai.transformer.splitter.TextSplitter;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.Ordered;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class ETLService {
  private ChatClient chatClient;
  @Autowired
  private VectorStore vectorStore;
  @Autowired
  private JdbcTemplate jdbcTemplate;

  public ETLService(ChatClient.Builder chatClientBuilder) {
    this.chatClient = chatClientBuilder
        .defaultAdvisors(
            new SimpleLoggerAdvisor(Ordered.LOWEST_PRECEDENCE - 1)
        )
        .build();
  }

  public void clearVectorStore() {
    jdbcTemplate.update("TRUNCATE TABLE vector_store");
    log.info("벡터 저장소 초기화 완료");
  }

  public String etlFromFile(String type, MultipartFile attach) throws IOException {
    log.info("ETL 시작 - 파일: {}, 구분: {}", attach.getOriginalFilename(), type);

    List<Document> documents = extractFromFile(attach);
    if (documents == null) {
      return ".txt, .pdf, .doc, .docx 파일 중에 하나를 올려주세요.";
    }
    log.info("추출된 Document 수: {} 개", documents.size());

    for (Document doc : documents) {
      doc.getMetadata().put("type", type);
      doc.getMetadata().put("filename", attach.getOriginalFilename());
    }

    documents = transform(documents);
    log.info("변환된 Document 수: {} 개", documents.size());

    vectorStore.add(documents);
    log.info("벡터 저장 완료");

    return String.format(
        "성공!\n- 파일명: %s\n- 구분: %s\n- 저장된 chunk 수: %d개",
        attach.getOriginalFilename(),
        type,
        documents.size()
    );
  }

  private List<Document> extractFromFile(MultipartFile attach) throws IOException {
    Resource resource = new ByteArrayResource(attach.getBytes());
    List<Document> documents = null;

    String contentType = attach.getContentType();
    log.info("파일 타입: {}", contentType);

    if ("text/plain".equals(contentType)) {
      DocumentReader reader = new TextReader(resource);
      documents = reader.read();
    } else if ("application/pdf".equals(contentType)) {
      DocumentReader reader = new PagePdfDocumentReader(resource);
      documents = reader.read();
    } else if (contentType != null && contentType.contains("wordprocessingml")) {
      DocumentReader reader = new TikaDocumentReader(resource);
      documents = reader.read();
    }

    return documents;
  }

  private List<Document> transform(List<Document> documents) {
    List<Document> result = new ArrayList<>();

    for (Document doc : documents) {
      String content = doc.getText();

      content = content.replaceAll("\\s+", " ");
      content = content.trim();

      // 빈 줄 기준으로 분할 (맛집 항목 사이)
      String[] items = content.split("\n\n+");

      for (String item : items) {
        String trimmed = item.trim();

        // 최소 길이 체크 (너무 짧은 건 제외)
        if (trimmed.length() > 20) {
          // 새 Document 생성 (메타데이터 유지)
          Document newDoc = new Document(trimmed, doc.getMetadata());
          result.add(newDoc);
        }
      }
    }

    log.info("총 {} 개의 청크 생성됨", result.size());
    return result;
  }

  // Flux 대신 String 반환
  public String ragChat(String question, String type) {
    log.info("RAG Chat 시작 - 질문: [{}], 구분: [{}]", question, type);

    if (!StringUtils.hasText(question)) {
      return "질문을 입력해주세요.";
    }

    SearchRequest.Builder searchRequestBuilder = SearchRequest.builder()
        .query(question)
        .similarityThreshold(0.5)
        .topK(10);

    if (StringUtils.hasText(type)) {
      searchRequestBuilder.filterExpression("type == '%s'".formatted(type));
      log.info("필터 적용: type == '{}'", type);
    }

    SearchRequest searchRequest = searchRequestBuilder.build();

    List<Document> searchResults = vectorStore.similaritySearch(searchRequest);
    log.info("검색 결과: {} 개 문서 발견", searchResults.size());

    if (searchResults.isEmpty()) {
      Integer totalDocs = jdbcTemplate.queryForObject(
          "SELECT COUNT(*) FROM vector_store",
          Integer.class
      );

      List<String> availableTypes = jdbcTemplate.queryForList(
          "SELECT DISTINCT metadata->>'type' as type FROM vector_store WHERE metadata->>'type' IS NOT NULL",
          String.class
      );

      return "업로드한 문서에서 관련 정보를 찾을 수 없습니다.\n\n" +
          "전체 문서 수: " + (totalDocs != null ? totalDocs : 0) + "개\n" +
          "사용 가능한 구분: " + availableTypes;
    }

    QuestionAnswerAdvisor questionAnswerAdvisor = QuestionAnswerAdvisor.builder(vectorStore)
        .searchRequest(searchRequest)
        .build();

    String answer = this.chatClient.prompt()
        .user(question)
        .advisors(questionAnswerAdvisor)
        .call()
        .content();

    log.info("응답 완료 - 길이: {} 자", answer.length());

    return answer;
  }
}

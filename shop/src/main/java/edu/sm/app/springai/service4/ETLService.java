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
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class ETLService {
    // ##### 필드 #####
    private ChatClient chatClient;
    @Autowired
    private VectorStore vectorStore;
    @Autowired private JdbcTemplate jdbcTemplate;


    // ##### 생성자 #####
    public ETLService(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder
                .defaultAdvisors(
                        new SimpleLoggerAdvisor(Ordered.LOWEST_PRECEDENCE - 1)
                )
                .build();
    }

    // ##### 벡터 저장소의 데이터를 모두 삭제하는 메소드 #####
    public void clearVectorStore() {
        jdbcTemplate.update("TRUNCATE TABLE vector_store");
    }


    // ##### 업로드된 파일을 가지고 ETL 과정을 처리하는 메소드 #####
    public String etlFromFile(String type, MultipartFile attach) throws IOException {

        // 추출하기
        List<Document> documents = extractFromFile(attach);
        if (documents == null) {
            return ".txt, .pdf, .doc, .docx 파일 중에 하나를 올려주세요.";
        }
        log.info("추출된 Document 수: {} 개", documents.size());

        // 메타데이터에 공통 정보 추가하기
        for (Document doc : documents) {
            doc.getMetadata().put("type", type);
            doc.getMetadata().put("source", attach.getOriginalFilename());
        }

        // 변환하기
        documents = transform(documents);
        log.info("변환된 Document 수: {} 개", documents.size());

        // 적재하기
        vectorStore.add(documents);

        return "올린 문서를 추출-변환-적재 완료 했습니다.";
    }

    // ##### 업로드된 파일로부터 텍스트를 추출하는 메소드 #####
    private List<Document> extractFromFile(MultipartFile attach) throws IOException {
        // 바이트 배열을 Resource로 생성
        Resource resource = new ByteArrayResource(attach.getBytes());

        List<Document> documents = null;
        String contentType = attach.getContentType();

        if (contentType == null) {
            return null;
        }

        if (contentType.equals("text/plain")) {
            // Text(.txt) 파일일 경우
            DocumentReader reader = new TextReader(resource);
            documents = reader.read();
        } else if (contentType.equals("application/pdf")) {
            // PDF(.pdf) 파일일 경우
            DocumentReader reader = new PagePdfDocumentReader(resource);
            documents = reader.read();
        } else if (contentType.contains("wordprocessingml") || contentType.equals("application/msword")) {
            // Word(.doc, .docx) 파일일 경우
            DocumentReader reader = new TikaDocumentReader(resource);
            documents = reader.read();
        }

        return documents;
    }

    // ##### 작은 크기로 분할하고 키워드 메타데이터를 추가하는 메소드 #####
    private List<Document> transform(List<Document> documents) {
        List<Document> transformedDocuments = null;

        // 작게 분할하기
        TokenTextSplitter tokenTextSplitter = new TokenTextSplitter();
        transformedDocuments = tokenTextSplitter.apply(documents);

        return transformedDocuments;
    }

    public Flux<String> ragChat(String question, String source) {  // type -> source로 변경
        SearchRequest.Builder searchRequestBuilder = SearchRequest.builder()
                .similarityThreshold(0.0)
                .topK(3);
        if (StringUtils.hasText(source)) {
            searchRequestBuilder.filterExpression("source == '%s'".formatted(source));  // 변경
        }
        SearchRequest searchRequest = searchRequestBuilder.build();

        // QuestionAnswerAdvisor 생성
        QuestionAnswerAdvisor questionAnswerAdvisor = QuestionAnswerAdvisor.builder(vectorStore)
                .searchRequest(searchRequest)
                .build();

        // 프롬프트를 LLM으로 전송하고 응답을 받는 코드
        Flux<String> answer = this.chatClient.prompt()
                .user(question)
                .advisors(questionAnswerAdvisor)
                .stream()
                .content();
        return answer;
    }

}
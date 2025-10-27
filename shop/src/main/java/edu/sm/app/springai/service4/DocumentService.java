package edu.sm.app.springai.service4;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class DocumentService {
    private final JdbcTemplate jdbcTemplate;
    private final ChatClient.Builder chatClientBuilder;
    private ChatClient chatClient;

    // 초기화
    public void init() {
        if (this.chatClient == null) {
            this.chatClient = chatClientBuilder.build();
            log.info("ChatClient 초기화 완료");
        }
    }

    // 특정 문서의 모든 내용 가져오기
    private String getDocumentsContentBySource(String source) {
        String sql = "SELECT content FROM vector_store WHERE metadata->>'source' = ?";
        List<String> chunks = jdbcTemplate.queryForList(sql, String.class, source);
        return String.join("\n\n", chunks);
    }

    // 업로드된 문서 목록 조회
    public List<Map<String, Object>> getDocumentList() {
        String sql = """
            SELECT metadata->>'type' as type,
                   metadata->>'source' as source,
                   COUNT(*) as chunk_count
            FROM vector_store
            GROUP BY metadata->>'type', metadata->>'source'
        """;
        log.debug("문서 목록 조회 SQL 실행: {}", sql);
        return jdbcTemplate.queryForList(sql);
    }

    // 타입별 문서 조회
    public List<Map<String, Object>> getDocumentsByType(String type) {
        log.info("문서 타입별 조회: {}", type);
        String sql = """
            SELECT metadata->>'source' as source,
                   COUNT(*) as chunk_count
            FROM vector_store
            WHERE metadata->>'type' = ?
            GROUP BY metadata->>'source'
        """;
        return jdbcTemplate.queryForList(sql, type);
    }

    // 특정 타입 문서 삭제
    public int deleteDocumentsByType(String type) {
        log.warn("문서 삭제 요청: type={}", type);
        String sql = "DELETE FROM vector_store WHERE metadata->>'type' = ?";
        return jdbcTemplate.update(sql, type);
    }

    // 특정 문서 삭제 (문서명 기반)
    public int deleteDocumentsBySource(String source) {
        log.warn("문서 삭제 요청: source={}", source);
        String sql = "DELETE FROM vector_store WHERE metadata->>'source' = ?";
        return jdbcTemplate.update(sql, source);
    }

    // 문서 요약 생성 (문서명 기반)
    public Flux<String> generateSummary(String source) {
        log.info("문서 요약 요청: source={}", source);
        init();

        try {
            String documentContent = getDocumentsContentBySource(source);

            // 내용 길이 제한
            int maxLength = 10000;
            if (documentContent.length() > maxLength) {
                documentContent = documentContent.substring(0, maxLength) + "\n...(내용 생략)...";
            }

            String prompt = String.format("""
                다음 문서의 내용을 3줄로 요약해주세요:
                - 핵심 주제
                - 중요 내용
                - 결론 또는 액션 아이템
                간결하고 명확하게 작성해주세요.

                --- 문서 내용 ---
                %s
            """, documentContent);

            return chatClient.prompt()
                    .user(prompt)
                    .stream()
                    .content()
                    .onErrorResume(error -> {
                        log.error("요약 생성 중 오류 (source={}): {}", source, error.getMessage());
                        if (error.getMessage() != null && error.getMessage().contains("429")) {
                            return Flux.just("API 요청 한도 초과. 1-2분 후 다시 시도해주세요.");
                        }
                        return Flux.just("요약 중 오류 발생: " + error.getMessage());
                    });
        } catch (Exception e) {
            log.error("요약 생성 중 오류 (source={}): {}", source, e.getMessage(), e);
            return Flux.just("요약 중 오류 발생: " + e.getMessage());
        }
    }

    // 키워드 추출 (문서명 기반)
    public String extractKeywords(String source) {
        log.info("키워드 추출 요청: source={}", source);
        init();

        try {
            String documentContent = getDocumentsContentBySource(source);

            // 내용 길이 제한
            int maxLength = 10000;
            if (documentContent.length() > maxLength) {
                documentContent = documentContent.substring(0, maxLength) + "\n...(내용 생략)...";
            }

            String prompt = String.format("""
                이 문서에서 핵심 키워드 5개를 추출해주세요.
                형식: 키워드1, 키워드2, 키워드3, 키워드4, 키워드5

                --- 문서 내용 ---
                %s
            """, documentContent);

            return chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();
        } catch (Exception e) {
            log.error("키워드 추출 중 오류 (source={}): {}", source, e.getMessage(), e);
            if (e.getMessage() != null && e.getMessage().contains("429")) {
                return "API 요청 한도 초과. 1-2분 후 다시 시도해주세요.";
            }
            return "키워드 추출 중 오류 발생: " + e.getMessage();
        }
    }

    // 문서 통계 정보
    public Map<String, Object> getDocumentStats() {
        log.debug("문서 통계 조회");
        String sql = """
            SELECT COUNT(DISTINCT metadata->>'type') as total_types,
                   COUNT(DISTINCT metadata->>'source') as total_documents,
                   COUNT(*) as total_chunks
            FROM vector_store
        """;
        return jdbcTemplate.queryForMap(sql);
    }

    // 문서 비교 분석 (문서명 기반)
    public Flux<String> compareDocuments(String source1, String source2) {
        log.info("문서 비교 요청: {} vs {}", source1, source2);
        init();

        try {
            String content1 = getDocumentsContentBySource(source1);
            String content2 = getDocumentsContentBySource(source2);

            // 내용이 너무 길면 제한
            int maxLength = 10000;
            if (content1.length() > maxLength) {
                content1 = content1.substring(0, maxLength) + "\n...(내용 생략)...";
            }
            if (content2.length() > maxLength) {
                content2 = content2.substring(0, maxLength) + "\n...(내용 생략)...";
            }

            String prompt = String.format("""
                다음 두 문서를 간단히 비교해주세요:
                
                [문서1: %s]
                %s
                
                [문서2: %s]
                %s
                
                공통점과 차이점을 각각 3가지씩만 간단히 설명해주세요.
            """, source1, content1, source2, content2);

            return chatClient.prompt()
                    .user(prompt)
                    .stream()
                    .content()
                    .onErrorResume(error -> {
                        log.error("문서 비교 중 오류: {}", error.getMessage());
                        if (error.getMessage() != null && error.getMessage().contains("429")) {
                            return Flux.just("⏳ API 요청 한도 초과. 1-2분 후 다시 시도해주세요.");
                        }
                        return Flux.just("문서 비교 중 오류 발생: " + error.getMessage());
                    });
        } catch (Exception e) {
            log.error("문서 비교 중 오류: {}", e.getMessage(), e);
            return Flux.just("문서 비교 중 오류 발생: " + e.getMessage());
        }
    }

    // 질문 템플릿 실행
    public Flux<String> executeQuestionTemplate(String templateName, String type) {
        log.info("질문 템플릿 실행: template={}, type={}", templateName, type);
        String question = switch (templateName) {
            case "summary" -> "이 문서의 핵심 내용을 3줄로 요약해주세요.";
            case "dates" -> "이 문서에서 언급된 주요 날짜와 기한을 모두 찾아주세요.";
            case "numbers" -> "이 문서의 중요한 숫자 데이터(금액, 수량 등)를 정리해주세요.";
            case "actions" -> "이 문서에서 필요한 액션 아이템이나 할 일을 추출해주세요.";
            case "keywords" -> "이 문서의 핵심 키워드 10개를 추출해주세요.";
            default -> "이 문서에 대해 설명해주세요.";
        };

        try {
            if (chatClient == null) init();
            return chatClient.prompt()
                    .user(question)
                    .stream()
                    .content()
                    .onErrorResume(error -> {
                        log.error("템플릿 실행 중 오류: {}", error.getMessage());
                        if (error.getMessage() != null && error.getMessage().contains("429")) {
                            return Flux.just("⏳ API 요청 한도 초과. 1-2분 후 다시 시도해주세요.");
                        }
                        return Flux.just("템플릿 실행 중 오류 발생: " + error.getMessage());
                    });
        } catch (Exception e) {
            log.error("템플릿 실행 중 오류: {}", e.getMessage(), e);
            return Flux.just("템플릿 실행 중 오류 발생: " + e.getMessage());
        }
    }
}
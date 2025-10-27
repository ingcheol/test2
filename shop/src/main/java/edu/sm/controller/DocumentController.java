package edu.sm.controller;

import edu.sm.app.springai.service4.AiChatService;
import edu.sm.app.springai.service4.DocumentService;
import edu.sm.app.springai.service4.DocumentToolsService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai4")
@Slf4j
@RequiredArgsConstructor
public class DocumentController {

    final private AiChatService aiChatService;
    final private DocumentToolsService documentToolsService;
    final private DocumentService documentService;

    @PostMapping("/txt-pdf-docx-etl")
    public String txtPdfDocxEtl(
            @RequestParam("type") String type,
            @RequestParam("attach") MultipartFile attach) throws Exception {
        String result = documentToolsService.etlFromFile(type, attach);
        return result;
    }

    @GetMapping("/rag-clear")
    public String ragClear() {
        documentToolsService.clearVectorStore();
        return "벡터 저장소의 데이터를 모두 삭제했습니다.";
    }

    @PostMapping("/rag-chat")
    public Flux<String> ragChat(
            @RequestParam("question") String question,
            @RequestParam("source") String source
    ) {
        return documentToolsService.ragChat(question, source)
                .onErrorResume(error -> {
                    log.error("RAG 질의 오류: {}", error.getMessage());
                    if (error.getMessage() != null && error.getMessage().contains("429")) {
                        return Flux.just("API 요청 한도 초과입니다. 잠시 후 다시 시도해주세요.");
                    }
                    return Flux.just("질의 중 오류가 발생했습니다.");
                });
    }

    @PostMapping("/chat")
    public Flux<String> inMemoryChatMemory(
            @RequestParam("question") String question, HttpSession session) {
        Flux<String> answer = aiChatService.chat(question, session.getId());
        return answer;
    }

    @GetMapping("/documents")
    public List<Map<String, Object>> getDocuments() {
        return documentService.getDocumentList();
    }

    @DeleteMapping("/documents/type/{type}")
    public String deleteDocumentsByType(@PathVariable String type) {
        int count = documentService.deleteDocumentsByType(type);
        return count + "개의 청크가 삭제되었습니다.";
    }

    @DeleteMapping("/documents/source/{source}")
    public String deleteDocumentsBySource(@PathVariable String source) {
        int count = documentService.deleteDocumentsBySource(source);
        return count + "개의 청크가 삭제되었습니다.";
    }

    @GetMapping("/stats")
    public Map<String, Object> getDocumentStats() {
        return documentService.getDocumentStats();
    }

    @GetMapping("/summary")
    public Flux<String> generateDocumentSummary(@RequestParam("source") String source) {
        log.info("/summary?source={} 요청 수신", source);
        return documentService.generateSummary(source)
                .onErrorResume(error -> {
                    log.error("요약 오류: {}", error.getMessage());
                    if (error.getMessage() != null && error.getMessage().contains("429")) {
                        return Flux.just("API 요청 한도 초과입니다. 잠시 후 다시 시도해주세요.");
                    }
                    return Flux.just("요약 중 오류가 발생했습니다.");
                });
    }

    @GetMapping("/keywords")
    public String extractKeywords(@RequestParam("source") String source) {
        log.info("/keywords?source={} 요청 수신", source);
        try {
            return documentService.extractKeywords(source);
        } catch (Exception e) {
            log.error("키워드 추출 오류: {}", e.getMessage());
            if (e.getMessage() != null && e.getMessage().contains("429")) {
                return "API 요청 한도 초과입니다. 잠시 후 다시 시도해주세요.";
            }
            return "키워드 추출 중 오류가 발생했습니다.";
        }
    }

    @GetMapping("/compare")
    public Flux<String> compareDocuments(
            @RequestParam("source1") String source1,
            @RequestParam("source2") String source2) {
        return documentService.compareDocuments(source1, source2)
                .onErrorResume(error -> {
                    log.error("문서 비교 오류: {}", error.getMessage());
                    if (error.getMessage() != null && error.getMessage().contains("429")) {
                        return Flux.just("API 요청 한도 초과입니다. 잠시 후 다시 시도해주세요.");
                    }
                    return Flux.just("문서 비교 중 오류가 발생했습니다.");
                });
    }

    @GetMapping("/template/{templateName}")
    public Flux<String> executeTemplate(
            @PathVariable String templateName,
            @RequestParam("type") String type) {
        return documentService.executeQuestionTemplate(templateName, type)
                .onErrorResume(error -> {
                    log.error("템플릿 실행 오류: {}", error.getMessage());
                    if (error.getMessage() != null && error.getMessage().contains("429")) {
                        return Flux.just("API 요청 한도 초과입니다. 잠시 후 다시 시도해주세요.");
                    }
                    return Flux.just("템플릿 실행 중 오류가 발생했습니다.");
                });
    }
}
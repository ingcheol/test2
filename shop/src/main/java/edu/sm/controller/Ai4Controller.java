package edu.sm.controller;

import edu.sm.app.springai.service4.AiChatService;
import edu.sm.app.springai.service4.ETLService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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

    @RequestMapping(value = "/rag-chat")
    public Flux<String> ragChat(
            @RequestParam("question") String question,
            @RequestParam("type") String type
    ) {
        Flux<String> answer = etlService.ragChat(question, type);
        return answer;
    }




    // ##### 요청 매핑 메소드 #####
    @RequestMapping(value = "/chat")
    public  Flux<String> inMemoryChatMemory(
            @RequestParam("question") String question, HttpSession session) {
        Flux<String> answer = aiChatService.chat(question, session.getId());
        return answer;
    }

}
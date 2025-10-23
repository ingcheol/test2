package edu.sm.controller;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import edu.sm.app.dto.AiMsg;
import edu.sm.app.springai.service3.AiImageService;
import edu.sm.sse.SseEmitters;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@Slf4j
@RequiredArgsConstructor
public class SseController {

    private final SseEmitters sseEmitters;
    private final AiImageService aiImageService;

    @GetMapping(value = "/connect/{id}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public ResponseEntity<SseEmitter> connect(@PathVariable("id") String clientId ) {
        SseEmitter emitter = new SseEmitter();
        sseEmitters.add(clientId,emitter);
        try {
            emitter.send(SseEmitter.event()
                    .name("connect")
                    .data(clientId)
            );
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return ResponseEntity.ok(emitter);
    }

    @GetMapping("/count")
    public void count(@RequestParam("num") int num) {
        sseEmitters.count(num);
        //return ResponseEntity.ok().build();
    }


    @RequestMapping("/aimsg")
    public void msg(@RequestParam("msg") String msg){
        log.info("msg:"+msg);
        sseEmitters.msg(msg);
    }

    @RequestMapping("/aimsg2")
    public void msg( @RequestParam(value="attach", required = false) MultipartFile attach) throws IOException {
        log.info(attach.getOriginalFilename());
        String base64File = Base64.getEncoder().encodeToString(attach.getBytes());
        log.info(base64File);
        String result = aiImageService.imageAnalysis2("이미지를 분석해줘",attach.getContentType(), attach.getBytes());
        AiMsg aiMsg = AiMsg.builder()
                .result(result)
                .base64File(base64File)
                .build();
        sseEmitters.msg(aiMsg);

    }
    @PostMapping(value = "/aimsg2", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, String>> receiveCarRecognition(@RequestBody Map<String, Object> messageData) {
        try {
            log.info("=== 차량 인식 데이터 수신 ===");
            log.info("Type: {}", messageData.get("type"));
            log.info("CarNumber: {}", messageData.get("carNumber"));
            log.info("Message: {}", messageData.get("message"));

            // AiMsg DTO 생성
            AiMsg aiMsg = AiMsg.builder()
                    .result((String) messageData.get("message"))
                    .base64File((String) messageData.get("base64File"))
                    .build();

            // 모든 연결된 클라이언트에게 SSE로 전송
            sseEmitters.msg(aiMsg);

            log.info("✅ SSE 전송 완료 - 차량번호: {}", messageData.get("carNumber"));

            Map<String, String> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "차량 인식 결과 전송 완료");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("❌ 차량 인식 데이터 처리 중 오류", e);

            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.status(500).body(errorResponse);
        }
    }

}
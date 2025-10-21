package edu.sm.controller;

import java.io.IOException;
import java.util.Base64;

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

}
package edu.sm.controller;

import java.io.IOException;
import edu.sm.sse.SseEmitters;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@Slf4j
@RequiredArgsConstructor
public class SseController {

    private final SseEmitters sseEmitters;

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
}
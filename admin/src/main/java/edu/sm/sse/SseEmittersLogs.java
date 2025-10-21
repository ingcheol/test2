package edu.sm.sse;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class SseEmittersLogs {
    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();

    public void add(String id, SseEmitter emitter) {
        this.emitters.put(id, emitter);
        emitter.onTimeout(() -> {
            log.info("Emitter timed out: {}", id);
            this.emitters.remove(id);
        });
        emitter.onCompletion(() -> {
            log.info("Emitter completed: {}", id);
            this.emitters.remove(id);
        });
        emitter.onError(e -> {
            log.error("Emitter error for id {}: {}", id, e.getMessage());
            this.emitters.remove(id);
        });
    }

    public void sendLogs(String data) {
        emitters.forEach((id, emitter) -> {
            try {
                emitter.send(SseEmitter.event()
                        .name("log-data")
                        .data(data));
            } catch (IOException e) {
                log.error("Failed to send log data to emitter for id {}: {}", id, e.getMessage());
                emitters.remove(id);
            }
        });
    }
}
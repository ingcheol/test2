package edu.sm.controller;

import edu.sm.app.dto.MsgTest;
import edu.sm.app.service.MsgTestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
@Slf4j
public class ChatHistoryController {

    private final MsgTestService msgTestService;

    @GetMapping("/history")
    public List<MsgTest> getChatHistory(
            @RequestParam("custId") String custId,
            @RequestParam(value = "limit", defaultValue = "50") int limit) {

        try {
            log.info("채팅 내역 조회 요청: custId={}, limit={}", custId, limit);
            List<MsgTest> messages = msgTestService.getRecentMessages(custId, "admin", limit);
            log.info("채팅 내역 조회 완료: {}개 메시지", messages.size());
            return messages;
        } catch (Exception e) {
            log.error("채팅 내역 조회 오류", e);
            return List.of();
        }
    }
}

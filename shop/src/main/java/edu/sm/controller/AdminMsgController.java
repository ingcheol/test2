package edu.sm.controller;

import edu.sm.app.msg.Msg;
import edu.sm.app.service.ChatService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Slf4j
@Controller
public class AdminMsgController {

    @Autowired
    SimpMessagingTemplate template;

    @Autowired
    ChatService chatService;

    @MessageMapping("/adminreceiveto")
    public void adminreceiveto(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        String id = msg.getSendid();
        String target = msg.getReceiveid();
        log.info("-------------------------1");
        log.info(target);

        try {
            chatService.saveMessage(
                    msg.getSendid(),      // senderId
                    msg.getReceiveid(),   // receiverId
                    msg.getContent1()     // message
            );
            log.info("✅ DB 저장 성공: {} → {} : {}",
                    msg.getSendid(), msg.getReceiveid(), msg.getContent1());
        } catch (Exception e) {
            log.error("❌ DB 저장 실패", e);
        }

        template.convertAndSend("/adminsend/to/" + target, msg);
        log.info("-------------------------2");
    }
}
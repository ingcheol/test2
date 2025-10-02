package edu.sm.controller;

import edu.sm.app.msg.Msg;
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

    @MessageMapping("/adminreceiveto") // 특정 Id에게 전송
    public void adminreceiveto(Msg msg, SimpMessageHeaderAccessor headerAccessor) {
        String id = msg.getSendid();
        String target = msg.getReceiveid();
        log.info("-------------------------1");
        log.info(target);

        template.convertAndSend("/adminsend/to/"+target,msg);
        log.info("-------------------------2");

    }
}
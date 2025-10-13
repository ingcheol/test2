package edu.sm.controller;

import edu.sm.app.dto.Marker;
import edu.sm.app.service.MarkerService;
import edu.sm.app.springai.service1.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import reactor.core.publisher.Flux;

@Controller
@Slf4j
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatController {
    @Value("${app.url.websocketurl}")
    String webSocketUrl;

    String dir="chat/";


    @RequestMapping("")
    public String main(Model model) {
        model.addAttribute("center",dir+"center");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chat1")
    public String chat1(Model model) throws Exception {
        model.addAttribute("websocketurl",webSocketUrl);
        model.addAttribute("center",dir+"chat1");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chat2")
    public String chat2(Model model) {
        model.addAttribute("websocketurl",webSocketUrl);
        model.addAttribute("center",dir+"chat2");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chat3")
    public String map2(Model model) {
        model.addAttribute("websocketurl",webSocketUrl);

        model.addAttribute("center",dir+"chat3");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chat4")
    public String chat4(Model model) {
        model.addAttribute("websocketurl",webSocketUrl);

        model.addAttribute("center",dir+"chat4");
        model.addAttribute("left",dir+"left");
        return "index";
    }
}
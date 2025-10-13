package edu.sm.controller;

import edu.sm.app.dto.Chat;
import edu.sm.app.dto.Product;
import edu.sm.app.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Random;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MainController {

    private final ChatService chatService;

    @Value("${app.url.sse}")
    String sseUrl;
    @Value("${app.url.mainsse}")
    String mainsseUrl;
    @Value("${app.url.websocketurl}")
    String websocketurl;

    @RequestMapping("/")
    public String main(Model model) {
        model.addAttribute("sseUrl", sseUrl);
        return "index";
    }

    @RequestMapping("/chart")
    public String chart(Model model) {
        model.addAttribute("mainsseUrl",mainsseUrl);
        model.addAttribute("center","chart");
        return "index";
    }
    @RequestMapping("/chat")
    public String chat(Model model) {
        model.addAttribute("websocketurl",websocketurl);
        model.addAttribute("center","chat");
        return "index";
    }
    @RequestMapping("/websocket")
    public String websocket(Model model) {
        model.addAttribute("websocketurl",websocketurl);
        model.addAttribute("center","websocket");
        return "index";
    }
    @RequestMapping("/admin")
    public String admin(
            @RequestParam(required = false) String userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "5") int pageSize,
            Model model) {

        List<Chat> allChats;
        if (userId != null && !userId.trim().isEmpty()) {
            allChats = chatService.getChatBetween("admin", userId);
            model.addAttribute("userId", userId);
        } else {
            allChats = chatService.getAllChats();
        }

        int totalChats = allChats.size();
        int totalPages = (int) Math.ceil((double) totalChats / pageSize);
        int startIndex = (page - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalChats);

        List<Chat> pagedChats = allChats.subList(startIndex, endIndex);

        model.addAttribute("admin", pagedChats);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalChats", totalChats);
        model.addAttribute("pageSize", pageSize);
        model.addAttribute("center", "admin");

        return "index";
    }
}
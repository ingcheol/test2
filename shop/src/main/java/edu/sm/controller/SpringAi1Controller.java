package edu.sm.controller;


import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequestMapping("/springai1")
public class SpringAi1Controller {

    String dir = "springai1/";

    @RequestMapping("")
    public String main(Model model) {
        model.addAttribute("center", dir + "center");
        model.addAttribute("left", dir + "left");
        return "index";
    }

    @RequestMapping("/ai1")
    public String ai1(Model model) {
        model.addAttribute("center", dir + "ai1");
        model.addAttribute("left", dir + "left");
        return "index";
    }
}
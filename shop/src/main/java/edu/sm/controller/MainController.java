package edu.sm.controller;

import edu.sm.app.dto.Product;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.Random;

@Controller
@Slf4j
public class MainController {

    @RequestMapping("/")
    public String main(Model model) {
        Random random = new Random();
        //log.info(""+random.nextInt(100)+1);
        return "index";
    }

    @RequestMapping("/audio")
    public String audio(Model model) {
        model.addAttribute("center", "audio");
        return "index";
    }

    @RequestMapping("/pic")
    public String pic(Model model) {
        model.addAttribute("center", "pic");
        return "index";
    }
    @RequestMapping("/wt1")
    public String wt1(Model model) {
        model.addAttribute("center", "wt1");
        return "index";
    }
    @RequestMapping("/wt2")
    public String wt2(Model model) {
        model.addAttribute("center", "wt2");
        return "index";
    }
    @RequestMapping("/wt3")
    public String wt3(Model model) {
        model.addAttribute("center", "wt3");
        return "index";
    }
}
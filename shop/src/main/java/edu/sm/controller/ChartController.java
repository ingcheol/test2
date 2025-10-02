package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequestMapping("/chart")
public class ChartController {

    String dir="chart/";

    @RequestMapping("")
    public String main(Model model) {
        model.addAttribute("center",dir+"center");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chart1")
    public String chart1(Model model) {
        model.addAttribute("center",dir+"chart1");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chart2")
    public String chart2(Model model) {
        model.addAttribute("center",dir+"chart2");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chart3")
    public String chart3(Model model) {
        model.addAttribute("center",dir+"chart3");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/chart4")
    public String chart4(Model model) {
        model.addAttribute("center",dir+"chart4");
        model.addAttribute("left",dir+"left");
        return "index";
    }
}
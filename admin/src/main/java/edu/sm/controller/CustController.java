package edu.sm.controller;

import com.github.pagehelper.PageInfo;
import edu.sm.app.dto.Cust;
import edu.sm.app.dto.CustSearch;
import edu.sm.app.service.CustService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@Slf4j
@RequestMapping("/cust")
@RequiredArgsConstructor
public class CustController {

    final CustService custService;


    String dir="cust/";

    @RequestMapping("/add")
    public String add(Model model) {
        model.addAttribute("center",dir+"add");
        return "index";
    }
    @RequestMapping("/addimpl")
    public String addimpl(Model model, Cust cust) throws Exception {

        custService.register(cust);
        return "redirect:/cust/get";
    }
    @RequestMapping("/updateimpl")
    public String updateimpl(Model model, Cust cust) throws Exception {
        custService.modify(cust);
        return "redirect:/cust/detail?id="+cust.getCustId();
    }
    @RequestMapping("/get")
    public String get(Model model) throws Exception {
        model.addAttribute("clist",custService.get());
        model.addAttribute("center",dir+"get");
        return "index";
    }
    @RequestMapping("/detail")
    public String detail(Model model, @RequestParam("id") String id) throws Exception {
        Cust cust = custService.get(id);

        model.addAttribute("cust",cust);
        model.addAttribute("center",dir+"detail");
        return "index";
    }
    @RequestMapping("/delete")
    public String delete(Model model, @RequestParam("id") String id) throws Exception {
        custService.remove(id);
        return "redirect:/cust/get";
    }

}
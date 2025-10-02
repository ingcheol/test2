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
    final BCryptPasswordEncoder bCryptPasswordEncoder;
    final StandardPBEStringEncryptor standardPBEStringEncryptor;

    String dir="cust/";

    @RequestMapping("")
    public String main(Model model) {
        model.addAttribute("center",dir+"center");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/add")
    public String add(Model model) {
        model.addAttribute("center",dir+"add");
        model.addAttribute("left",dir+"left");
        return "index";
    }
    @RequestMapping("/addimpl")
    public String addimpl(Model model, Cust cust) throws Exception {
        cust.setCustPwd(bCryptPasswordEncoder.encode(cust.getCustPwd()));
        cust.setCustAddr(standardPBEStringEncryptor.encrypt(cust.getCustAddr()));
        custService.register(cust);
        return "redirect:/cust/get";
    }
    @RequestMapping("/get")
    public String get(Model model) throws Exception {
        List<Cust> list = null;
        list = custService.get();

        model.addAttribute("clist", list);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"get");
        return "index";
    }
    @RequestMapping("/search")
    public String search(Model model, CustSearch custSearch ) throws Exception {
        List<Cust> list = null;
        list = custService.searchCustList(custSearch);

        model.addAttribute("custName", custSearch.getCustName());
        model.addAttribute("startDate", custSearch.getStartDate());
        model.addAttribute("endDate", custSearch.getEndDate());

        model.addAttribute("clist", list);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"get");

        return "index";
    }
//    @RequestMapping("/getpage")
//    public String getpage(@RequestParam(value="pageNo", defaultValue = "1") int pageNo, Model model) throws Exception {
//        PageInfo<Cust> p = null;
//        p = new PageInfo<>(custService.getPage(pageNo), 3); // 5:하단 네비게이션 개수
//        model.addAttribute("target","/cust");
//        model.addAttribute("clist",p);
//        model.addAttribute("left", dir+"left");
//        model.addAttribute("center", dir+"getpage");
//        return "index";
//    }
    @RequestMapping("/searchpage")
    public String searchpage(@RequestParam(value="pageNo", defaultValue = "1") int pageNo, Model model,
                          CustSearch custSearch) throws Exception {
        PageInfo<Cust> p = null;
        p = new PageInfo<>(custService.getPageSearch(pageNo, custSearch), 3); // 5:하단 네비게이션 개수

        model.addAttribute("custName", custSearch.getCustName());
        model.addAttribute("startDate", custSearch.getStartDate());
        model.addAttribute("endDate", custSearch.getEndDate());

        model.addAttribute("target","/cust");
        model.addAttribute("cpage",p);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"getpage");
        return "index";
    }

}
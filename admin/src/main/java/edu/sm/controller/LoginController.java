package edu.sm.controller;

import edu.sm.app.dto.Admin;
import edu.sm.app.dto.Cust;
import edu.sm.app.service.AdminService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@Slf4j
@RequiredArgsConstructor
public class LoginController {

    final AdminService adminService;
    final BCryptPasswordEncoder bCryptPasswordEncoder;

    @RequestMapping("/loginimpl")
    public String loginimpl(Model model, @RequestParam("id") String adminId,
                            @RequestParam("pwd") String adminPwd, HttpSession httpSession) throws Exception {
        Admin dbadmin =  adminService.get(adminId);
        if(dbadmin != null && bCryptPasswordEncoder.matches(adminPwd, dbadmin.getAdminPwd())){
            httpSession.setAttribute("admin",dbadmin);
            return "redirect:/";
        }
        model.addAttribute("loginfail","fail");
        model.addAttribute("msg","로그인 실패!!!");
        return "index";
    }
    @RequestMapping("/logoutimpl")
    public String logout(Model model, HttpSession httpSession) throws Exception {
        if(httpSession != null){
            httpSession.invalidate();
        }
        return "redirect:/";
    }

}
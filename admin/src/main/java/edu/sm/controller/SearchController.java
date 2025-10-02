package edu.sm.controller;

import edu.sm.app.dto.CustSearch;
import edu.sm.app.dto.ProductSearch;
import edu.sm.app.service.CustService;
import edu.sm.app.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequiredArgsConstructor
public class SearchController {

    final CustService custService;
    final ProductService  productService;

    @RequestMapping("/custsearch")
    public String custsearch(Model model, CustSearch  custSearch) throws Exception {
        model.addAttribute("searchcust", custSearch);
        model.addAttribute("searchtype", "cust");
        model.addAttribute("clist", custService.searchCustList(custSearch));
        model.addAttribute("center","cust/get");
        return "index";
    }
    @RequestMapping("/productsearch")
    public String productsearch(Model model, ProductSearch  productSearch) throws Exception {
        model.addAttribute("searchproduct", productSearch);
        model.addAttribute("searchtype", "product");
        model.addAttribute("plist", productService.searchProductList(productSearch));
        model.addAttribute("center","product/get");
        return "index";
    }

}
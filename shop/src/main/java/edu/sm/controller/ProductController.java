package edu.sm.controller;

import com.github.pagehelper.PageInfo;
import edu.sm.app.dto.Cust;
import edu.sm.app.dto.CustSearch;
import edu.sm.app.dto.Product;
import edu.sm.app.dto.ProductSearch;
import edu.sm.app.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@Slf4j
@RequestMapping("/product")
@RequiredArgsConstructor
public class ProductController {
    final ProductService productService;

    String dir="product/";

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
    @RequestMapping("/get")
    public String get(Model model) throws Exception {
        List<Product> list = null;

        list = productService.get();
        model.addAttribute("plist", list);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"get");
        return "index";
    }
    @RequestMapping("/registerimpl")
    public String registerimpl(Model model, Product product) throws Exception {
        productService.register(product);
        return "redirect:/product/get";
    }
//    @RequestMapping("/getpage")
//    public String getpage(@RequestParam(value="pageNo", defaultValue = "1") int pageNo, Model model) throws Exception {
//        PageInfo<Product> p = null;
//        p = new PageInfo<>(productService.getPage(pageNo), 3); // 5:하단 네비게이션 개수
//        model.addAttribute("target","/product");
//        model.addAttribute("clist",p);
//        model.addAttribute("left", dir+"left");
//        model.addAttribute("center", dir+"getpage");
//        return "index";
//    }
    @RequestMapping("/searchpage")
    public String searchpage(@RequestParam(value="pageNo", defaultValue = "1") int pageNo, Model model,
                             ProductSearch productSearch) throws Exception {
        PageInfo<Product> p = null;
        p = new PageInfo<>(productService.getPageSearch(pageNo, productSearch), 3); // 5:하단 네비게이션 개수

        model.addAttribute("productName", productSearch.getProductName());
        model.addAttribute("startPrice", productSearch.getStartPrice());
        model.addAttribute("endPrice", productSearch.getEndPrice());
        model.addAttribute("cateId", productSearch.getCateId());

        model.addAttribute("target","/product");
        model.addAttribute("cpage",p);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"getpage");
        return "index";
    }
    @RequestMapping("/search")
    public String search(Model model, ProductSearch productSearch ) throws Exception {
        List<Product> list = null;
        list = productService.searchProductList(productSearch);

        model.addAttribute("productName", productSearch.getProductName());
        model.addAttribute("startPrice", productSearch.getStartPrice());
        model.addAttribute("endPrice", productSearch.getEndPrice());
        model.addAttribute("cateId", productSearch.getCateId());

        model.addAttribute("plist", list);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"get");

        return "index";
    }

    @RequestMapping("/updateimpl")
    public String updateimpl(Model model, Product product) throws Exception {
        productService.modify(product);
        return "redirect:/product/detail?id="+product.getProductId();
    }
    @RequestMapping("/delete")
    public String delete(Model model, @RequestParam("id") int id) throws Exception {
        productService.remove(id);
        return "redirect:/product/get";
    }
    @RequestMapping("/detail")
    public String detail(Model model, @RequestParam("id") int id) throws Exception {
        Product product = null;
        product = productService.get(id);
        model.addAttribute("p", product);
        model.addAttribute("left", dir+"left");
        model.addAttribute("center", dir+"detail");
        log.info(product.getProductId()+","+product.getProductName());
        return "index";
    }
}
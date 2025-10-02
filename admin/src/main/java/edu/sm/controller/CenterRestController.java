package edu.sm.controller;

import edu.sm.app.dto.CustSearch;
import edu.sm.app.dto.ProductSearch;
import edu.sm.app.service.CustService;
import edu.sm.app.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.simple.JSONArray;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;

@RestController
@Slf4j
@RequiredArgsConstructor
public class CenterRestController {

    @RequestMapping("/areachart")
    public Object areachart() throws Exception {
        JSONArray ja = new JSONArray();
        Random r = new Random();
        for(int i=0; i<12; i++){
            ja.add(r.nextInt(30)+1);
        }
        return ja;
    }
    @RequestMapping("/piechart")
    public Object piechart() throws Exception {
        JSONArray ja = new JSONArray();
        Random r = new Random();
        for(int i=0; i<3; i++){
            ja.add(r.nextInt(30)+1);
        }
        return ja;
    }

}
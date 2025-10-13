package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/maplog")
@Slf4j
public class MapLogController {

    @PostMapping("/click")
    public String logMarkerClick(
            @RequestParam("name") String name,
            @RequestParam("region") String region) {

        // 로그 형식: 날짜, 지역, 이름
        log.info("{}, {}", region, name);

        return "success";
    }
}

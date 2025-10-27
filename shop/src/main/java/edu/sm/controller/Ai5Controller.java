package edu.sm.controller;



import edu.sm.app.springai.service5.BoomBarrierService;
import edu.sm.app.springai.service5.GoService;
import edu.sm.app.springai.service5.HeatingSystemService;
import edu.sm.app.springai.service5.RecommendMovieService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/ai5")
@Slf4j
@RequiredArgsConstructor
public class Ai5Controller {

    final private HeatingSystemService heatingSystemService;
    final private RecommendMovieService recommendMovieService;
    final private BoomBarrierService boomBarrierService;
    final private GoService goService;



    // ##### 요청 매핑 메소드 #####
    @RequestMapping(value = "/heating-system-tools")
    public String heatingSystemTools(@RequestParam("question") String question) {
        String answer = heatingSystemService.chat(question);
        return answer;
    }

    @RequestMapping( value = "/recommend-movie-tools")
    public String recommendMovieTools(@RequestParam("question") String question,
                                      @RequestParam("custid") String custId) {
        String answer = recommendMovieService.chat(question,custId);
        return answer;
    }

    @RequestMapping( value = "/go-tools")
    public String goTools(@RequestParam("question") String question) {
        String answer = goService.chat(question);
        return answer;
    }

    @RequestMapping( value = "/boom-barrier-tools")
    public String boomBarrierTools(
            @RequestParam("attach") MultipartFile attach) throws IOException {
        String answer = boomBarrierService.chat(
                attach.getContentType(), attach.getBytes());
        return answer;
    }

}
package edu.sm.controller;

import edu.sm.app.springai.service1.*;
import edu.sm.app.springai.service2.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ai2")
@Slf4j
@RequiredArgsConstructor
public class Ai2Controller {

  final private AiServiceListOutputConverter aiServiceloc;
  final private AiServiceMapOutputConverter aiServicemoc;


  // ##### 요청 매핑 메소드 #####
  @RequestMapping(value = "/list-output-converter")
  public List<String> listOutputConverter(@RequestParam("city") String city) {
    List<String> hotelList = aiServiceloc.listOutputConverterHighLevel(city);
    // List<String> hotelList = aiServiceloc.listOutputConverterHighLevel(city);
    return hotelList;
  }

  @RequestMapping(value = "/map-output-converter")
  public Map<String, Object> mapOutputConverter(@RequestParam("hotel") String hotel) {
    //Map<String, Object> hotelInfo = aiServicemoc.mapOutputConverterLowLevel(hotel);
    Map<String, Object> hotelInfo = aiServicemoc.mapOutputConverterHighLevel(hotel);
    return hotelInfo;
  }

//  @RequestMapping(value = "/system-message")
//  public ReviewClassification beanOutputConverter2(@RequestParam("review") String review) {
//    ReviewClassification reviewClassification = aiServicesm.classifyReview(review);
//    return reviewClassification;
//  }
}

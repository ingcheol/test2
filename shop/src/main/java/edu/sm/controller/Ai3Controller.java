package edu.sm.controller;

import edu.sm.app.dto.AccountBook;
import edu.sm.app.springai.service3.AiImageService;
import edu.sm.app.springai.service3.AiSttService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.web.bind.annotation.PostMapping;

@RestController
@RequestMapping("/ai3")
@Slf4j
@RequiredArgsConstructor
public class Ai3Controller {

  final private AiSttService aisttService;
  final private AiImageService aiImageService;

  @RequestMapping(value = "/stt")
  public String stt(@RequestParam("speech") MultipartFile speech) throws IOException {
    String text = aisttService.stt(speech);
    return text;
  }
  @RequestMapping(value = "/stt2")
  public String stt2(@RequestParam("speech") MultipartFile speech) throws IOException {
    String text = aisttService.stt(speech);
    Map<String, String> views = new ConcurrentHashMap<>();
    log.info("|"+text+"|");

    views.put("로그인", "/login");
    views.put("회원가입", "/register");
    views.put("회원 가입", "/register");
    views.put("홈", "/");
    views.put("메인", "/");

    String result = views.get(text.trim());
    return result;
  }


  @RequestMapping(value = "/tts")
  public byte[] tts(@RequestParam("text") String text) {
    byte[] bytes = aisttService.tts(text);
    return bytes;
  }

  @RequestMapping(value = "/tts2")
  public Map<String, String> tts2(@RequestParam("text") String text) {
    Map<String, String> response = aisttService.tts2(text);
    return response;
  }

  @RequestMapping(value = "/translate")
  public Map<String, String> translate(
          @RequestParam("speech") MultipartFile speech,
          @RequestParam(value = "targetLang", defaultValue = "en") String targetLang
  ) throws IOException {
    Map<String, String> result = aisttService.translateVoice(speech, targetLang);
    return result;
  }

  @RequestMapping(value = "/accountbook")
  public List<AccountBook> accountbook(@RequestParam("question") String question) {
    return aisttService.extractAccountBookData(question);
  }

  @RequestMapping(value = "/chat-text")
  public Map<String, String> chatText(@RequestParam("question") String question) {
    Map<String, String> response = aisttService.chatText(question);
    return response;
  }


  @RequestMapping(value = "/image-analysis")
  public Flux<String> imageAnalysis(
          @RequestParam("question") String question,
          @RequestParam(value="attach", required = false) MultipartFile attach) throws IOException {
    // 이미지가 업로드 되지 않았을 경우
    if (attach == null || !attach.getContentType().contains("image/")) {
      Flux<String> response = Flux.just("이미지를 올려주세요.");
      return response;
    }

    Flux<String> flux = aiImageService.imageAnalysis(question, attach.getContentType(), attach.getBytes());
    return flux;
  }

  @RequestMapping(value = "/image-analysis2")
  public Map<String,String> imageAnalysis2(
          @RequestParam("question") String question,
          @RequestParam(value="attach", required = false) MultipartFile attach) throws IOException {

    String result = aiImageService.imageAnalysis2(question, attach.getContentType(), attach.getBytes());
    byte[] audio = aisttService.tts(result);
    String base64Audio = Base64.getEncoder().encodeToString(audio);

    // 텍스트 답변과 음성 답변을 Map에 저장
    Map<String, String> response = new HashMap<>();
    response.put("text", result);
    response.put("audio", base64Audio);

    return response;
  }


  @RequestMapping( value = "/image-generate" )
  public String imageGenerate(@RequestParam("question") String question) {
    log.info("start imageGenerate-------------");
    try {
      String b64Json = aiImageService.generateImage(question);
      return b64Json;
    } catch(Exception e) {
      e.printStackTrace();
      return "Error: " + e.getMessage();
    }
  }



  // ai97.jsp가 호출할 메소드
  @PostMapping("/vehicle-inspection") // ai97.jsp의 fetch 경로와 일치
  public Map<String,String> vehicleInspection(
          @RequestParam("question") String question,
          @RequestParam(value="attach", required = false) MultipartFile attach,
          @RequestParam(value="language", defaultValue = "ko") String language) throws IOException { // 'language' 파라미터 추가!

    log.info("AI 차량 분석 요청 받음 (vehicle-inspection): " + language);

    // 1. aiImageService로 텍스트 분석 (기존 /image-analysis2 와 동일)
    // (JSP에서 이미지를 보냈는지 확인하므로 여기서는 null 체크 생략)
    String result = aiImageService.imageAnalysis2(question, attach.getContentType(), attach.getBytes());

    // 2. aisttService로 음성 변환
    // TODO: aisttService.tts가 'language' 파라미터를 지원하도록 수정해야 할 수 있습니다.
    // (예: aisttService.tts(result, language))
    // 지금은 /image-analysis2와 동일하게 한국어(기본값)로 음성을 생성합니다.
    byte[] audio = aisttService.tts(result);
    String base64Audio = Base64.getEncoder().encodeToString(audio);

    // 3. Map(JSON)으로 반환 (기존 /image-analysis2 와 동일)
    Map<String, String> response = new HashMap<>();
    response.put("text", result);    // AI 분석 텍스트
    response.put("audio", base64Audio);  // TTS 변환 Base64

    return response;
  }
}
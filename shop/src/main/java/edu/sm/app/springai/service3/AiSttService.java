package edu.sm.app.springai.service3;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.audio.transcription.AudioTranscriptionPrompt;
import org.springframework.ai.audio.transcription.AudioTranscriptionResponse;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.openai.OpenAiAudioSpeechModel;
import org.springframework.ai.openai.OpenAiAudioSpeechOptions;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.ai.openai.OpenAiAudioTranscriptionOptions;
import org.springframework.ai.openai.api.OpenAiAudioApi.SpeechRequest;
import org.springframework.ai.openai.api.OpenAiAudioApi.SpeechRequest.AudioResponseFormat;
import org.springframework.ai.openai.audio.speech.SpeechPrompt;
import org.springframework.ai.openai.audio.speech.SpeechResponse;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class AiSttService {
  // ##### 필드 #####
  private ChatClient chatClient;
  private OpenAiAudioTranscriptionModel openAiAudioTranscriptionModel;
  private OpenAiAudioSpeechModel openAiAudioSpeechModel;

  // ##### 생성자 #####
  public AiSttService(ChatClient.Builder chatClientBuilder,
                      OpenAiAudioTranscriptionModel openAiAudioTranscriptionModel,
                      OpenAiAudioSpeechModel openAiAudioSpeechModel) {
    chatClient = chatClientBuilder.build();
    this.openAiAudioTranscriptionModel = openAiAudioTranscriptionModel;
    this.openAiAudioSpeechModel = openAiAudioSpeechModel;
  }

  public Map<String, String> translateVoice(MultipartFile audioFile, String targetLang) throws IOException {
    // 1. 음성을 텍스트로 변환 (언어 자동 감지)
    Path tempFile = Files.createTempFile("multipart-", audioFile.getOriginalFilename());
    audioFile.transferTo(tempFile);
    Resource audioResource = new FileSystemResource(tempFile);

    OpenAiAudioTranscriptionOptions options = OpenAiAudioTranscriptionOptions.builder()
        .model("whisper-1")
        .build();

    AudioTranscriptionPrompt prompt = new AudioTranscriptionPrompt(audioResource, options);
    AudioTranscriptionResponse response = openAiAudioTranscriptionModel.call(prompt);
    String originalText = response.getResult().getOutput();

    log.info("인식된 텍스트: " + originalText);

    // 2. 언어 감지
    String detectPrompt = """
        Detect the language of this text and return ONLY the language code.
        Return "ko" for Korean, "en" for English, "ja" for Japanese, "zh" for Chinese.
        Only return the 2-letter code, nothing else.
        
        Text: %s
        """.formatted(originalText);

    String detectedLang = chatClient.prompt()
        .user(detectPrompt)
        .call()
        .content()
        .trim()
        .toLowerCase();

    if (!detectedLang.matches("ko|en|ja|zh")) {
      detectedLang = "en";
    }

    log.info("감지된 언어: " + detectedLang + ", 번역 대상 언어: " + targetLang);

    // 3. 번역 (사용자가 선택한 언어로)
    Map<String, String> langNames = new HashMap<>();
    langNames.put("ko", "Korean");
    langNames.put("en", "English");
    langNames.put("ja", "Japanese");
    langNames.put("zh", "Chinese");

    String translatePrompt = """
        You are a professional translator.
        Translate the following text from %s to %s.
        Provide ONLY the translation without any explanations.
        Make it sound natural and conversational.
        Do not use any markdown formatting.
        
        Text: %s
        """.formatted(langNames.get(detectedLang), langNames.get(targetLang), originalText);

    String translatedText = chatClient.prompt()
        .user(translatePrompt)
        .call()
        .content()
        .trim();

    log.info("번역된 텍스트: " + translatedText);

    // 4. TTS
    byte[] audioBytes = tts(translatedText);
    String base64Audio = Base64.getEncoder().encodeToString(audioBytes);

    // 5. 결과 반환
    Map<String, String> result = new HashMap<>();
    result.put("originalText", originalText);
    result.put("translatedText", translatedText);
    result.put("detectedLang", detectedLang);
    result.put("targetLang", targetLang);
    result.put("audio", base64Audio);

    Files.deleteIfExists(tempFile);

    return result;
  }

  // ##### 메소드 #####
  public String stt(MultipartFile multipartFile) throws IOException {

    Path tempFile = Files.createTempFile("multipart-", multipartFile.getOriginalFilename());
    multipartFile.transferTo(tempFile);
    Resource audioResource = new FileSystemResource(tempFile);

    // 모델 옵션 설정
    OpenAiAudioTranscriptionOptions options = OpenAiAudioTranscriptionOptions.builder()
            .model("whisper-1")
            .language("ko") // 입력 음성 언어의 종류 설정, 출력 언어에도 영향을 미침
            .build();

    // 프롬프트 생성
    AudioTranscriptionPrompt prompt = new AudioTranscriptionPrompt(audioResource, options);

    // 모델을 호출하고 응답받기
    AudioTranscriptionResponse response = openAiAudioTranscriptionModel.call(prompt);
    String text = response.getResult().getOutput();
    log.info(text);

    return text;
  }


  public byte[] tts(String text) {
    // 모델 옵션 설정
    OpenAiAudioSpeechOptions options = OpenAiAudioSpeechOptions.builder()
        .model("gpt-4o-mini-tts")
        .voice(SpeechRequest.Voice.ALLOY)
        .responseFormat(AudioResponseFormat.MP3)
        .speed(1.0f)
        .build();

    // 프롬프트 생성
    SpeechPrompt prompt = new SpeechPrompt(text, options);

    // 모델을 호출하고 응답받기
    SpeechResponse response = openAiAudioSpeechModel.call(prompt);
    byte[] bytes = response.getResult().getOutput();

    return bytes;
  }

  public Map<String, String> tts2(String text) {
    // 모델 옵션 설정
    OpenAiAudioSpeechOptions options = OpenAiAudioSpeechOptions.builder()
            .model("gpt-4o-mini-tts")
            .voice(SpeechRequest.Voice.ALLOY)
            .responseFormat(AudioResponseFormat.MP3)
            .speed(1.0f)
            .build();

    // 프롬프트 생성
    SpeechPrompt prompt = new SpeechPrompt(text, options);

    // 모델을 호출하고 응답받기
    SpeechResponse response = openAiAudioSpeechModel.call(prompt);
    byte[] bytes = response.getResult().getOutput();
    String base64Audio = Base64.getEncoder().encodeToString(bytes);

    Map<String, String> result = new HashMap<>();
    result.put("audio", base64Audio);

    return result;
  }

  public Map<String, String> chatText(String question) {
    // LLM로 요청하고, 텍스트 응답 얻기
    String textAnswer = chatClient.prompt()
        .system("50자 이내로 한국어로 답변해주세요.")
        .user(question)
        .call()
        .content();

    // TTS 모델로 요청하고 응답으로 받은 음성 데이터를 base64 문자열로 변환
    byte[] audio = tts(textAnswer);
    String base64Audio = Base64.getEncoder().encodeToString(audio);

    // 텍스트 답변과 음성 답변을 Map에 저장
    Map<String, String> response = new HashMap<>();
    response.put("text", textAnswer);
    response.put("audio", base64Audio);

    return response;
  }

}

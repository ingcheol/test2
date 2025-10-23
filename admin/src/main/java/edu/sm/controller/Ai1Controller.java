package edu.sm.controller;

import edu.sm.app.springai.service1.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/ai1")
@Slf4j
@RequiredArgsConstructor
public class Ai1Controller {
    final AiServiceByChatClient ai1ServiceByChatClient;
    final AiServiceChainOfThoughtPrompt ai1Servicechainofthoughtprompt;
    final AiServiceFewShotPrompt aiServiceFewShotPrompt;
    final AiServicePromptTemplate aiServicePromptTemplate;
    final AiServiceStepBackPrompt aiServiceStepBackPrompt;

    @RequestMapping("/chat-model")
    public String chatModel(@RequestParam("question") String question){
        return ai1ServiceByChatClient.generateText(question);
    }
    @RequestMapping("/chat-model-stream")
    public Flux<String> chatModelStream(@RequestParam("question") String question){
        return ai1ServiceByChatClient.generateStreamText(question);
    }
    @RequestMapping("/chat-of-thought")
    public Flux<String> chatOfThought(@RequestParam("question") String question){
        return ai1Servicechainofthoughtprompt.chainOfThought(question);
    }
    @RequestMapping("/few-shot-prompt")
    public String fewShotPrompt(@RequestParam("question") String question) {
        return aiServiceFewShotPrompt.fewShotPrompt(question);
    }
    @RequestMapping(value = "/prompt-template")
    public Flux<String> promptTemplate(      @RequestParam("question") String question,
                                             @RequestParam("language") String language) {
        Flux<String> response = aiServicePromptTemplate.promptTemplate3(question, language);
        return response;
    }
    @RequestMapping("role-assignment")
    public Flux<String> roleAssignment(@RequestParam("requirements") String requirements){
        return aiServicePromptTemplate.roleAssignment(requirements);
    }
    @PostMapping(value = "/step-back-prompt")
    public String stepBackPrompt(@RequestParam("question") String question) throws Exception {
        String answer = aiServiceStepBackPrompt.stepBackPrompt(question);
        return answer;
    }
}


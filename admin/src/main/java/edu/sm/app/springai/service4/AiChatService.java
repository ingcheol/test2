package edu.sm.app.springai.service4;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.PromptChatMemoryAdvisor;
import org.springframework.ai.chat.client.advisor.SimpleLoggerAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

@Service
@Slf4j
public class AiChatService {
    // ##### 필드 #####
    private ChatClient chatClient;

    // ##### 생성자 #####
    public AiChatService(
            ChatMemory chatMemory,
            ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder
                .defaultAdvisors(
                        //MessageChatMemoryAdvisor.builder(chatMemory).build(),
                        PromptChatMemoryAdvisor.builder(chatMemory).build(),
                        new SimpleLoggerAdvisor(Ordered.LOWEST_PRECEDENCE-1)
                )
                .build();
    }


    // ##### 메소드 #####
    public Flux<String> chat(String userText, String conversationId) {
//    String answer = chatClient.prompt()
//      .user(userText)
//      .advisors(advisorSpec -> advisorSpec.param(
//        ChatMemory.CONVERSATION_ID, conversationId
//      ))
//      .call()
//      .content();
        Flux<String> answer = chatClient.prompt()
                .user(userText)
                .advisors(advisorSpec -> advisorSpec.param(
                        ChatMemory.CONVERSATION_ID, conversationId
                ))
                .stream()
                .content();
        return answer;
    }
}
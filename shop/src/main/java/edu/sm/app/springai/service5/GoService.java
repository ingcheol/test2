package edu.sm.app.springai.service5;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class GoService {
    // ##### 필드 #####
    private ChatClient chatClient;

    @Autowired
    private GoTools goTools;

    // ##### 생성자 #####
    public GoService(ChatModel chatModel) {
        this.chatClient = ChatClient.builder(chatModel).build();
    }

    // ##### LLM과 대화하는 메소드 #####
    public String chat(String question) {
        String answer = chatClient.prompt()
                .user(question)
                .tools(goTools)
                .call()
                .content();
        return answer;
    }
}
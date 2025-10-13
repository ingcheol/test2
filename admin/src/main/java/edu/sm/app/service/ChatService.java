package edu.sm.app.service;

import edu.sm.app.dto.Chat;
import edu.sm.app.repository.ChatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMapper chatMapper;

    public void saveMessage(String senderId, String receiverId, String message) {
        Chat chat = new Chat();
        chat.setSenderId(senderId);
        chat.setReceiverId(receiverId);
        chat.setMessage(message);
        chatMapper.save(chat);
    }
    public List<Chat> getSentMessages(String senderId) {
        return chatMapper.findBySenderId(senderId);
    }
    public List<Chat> getReceivedMessages(String receiverId) {
        return chatMapper.findByReceiverId(receiverId);
    }
    public List<Chat> getChatBetween(String userId1, String userId2) {
        return chatMapper.findBetweenUsers(userId1, userId2);
    }
    public List<Chat> getAllChats() {
        return chatMapper.findAll();
    }
    public Optional<Chat> getChatById(int chatId) {
        return chatMapper.findById(chatId);
    }
}
package edu.sm.app.repository;

import edu.sm.app.dto.Chat;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface ChatMapper {
    void save(Chat chat);
    List<Chat> findBySenderId(@Param("senderId") String senderId);
    List<Chat> findByReceiverId(@Param("receiverId") String receiverId);
    List<Chat> findBetweenUsers(@Param("userId1") String userId1,
                                @Param("userId2") String userId2);
    List<Chat> findAll();
    Optional<Chat> findById(@Param("chatId") int chatId);
}
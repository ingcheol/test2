package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Chat {
    private int chatId;
    private String senderId;    // 보낸 사람
    private String receiverId;  // 받는 사람
    private String message;
    private Timestamp regdate;
}
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
    private String senderId;
    private String receiverId;
    private String message;
    private Timestamp regdate;
}
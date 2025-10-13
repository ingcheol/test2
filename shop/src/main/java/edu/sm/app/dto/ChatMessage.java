package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessage {
    private String sendid;      // 보낸 사람 ID
    private String receiveid;   // 받는 사람 ID
    private String content;    // 메시지 내용
}
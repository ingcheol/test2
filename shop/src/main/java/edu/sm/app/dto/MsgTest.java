package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MsgTest {
    private Integer msgId;
    private String sendid;
    private String receiveid;
    private String content1;
    private LocalDateTime rdate;  // 이 필드가 있어야 함
}

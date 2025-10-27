package edu.sm.controller;

import edu.sm.app.dto.AccountBook;
import edu.sm.app.dto.Cust;
import edu.sm.app.service.AccountBookService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/accountbook")
@Slf4j
@RequiredArgsConstructor
public class AccountBookController {

  private final AccountBookService accountBookService;

  private String getUserIdFromSession(HttpSession session) {
    Cust cust = (Cust) session.getAttribute("cust");
    if (cust != null) {
      return cust.getCustId();
    }
    return null;
  }

  @GetMapping("/list")
  public ResponseEntity<?> getAccountBooks(HttpSession session) {
    try {
      String userId = getUserIdFromSession(session);

      if (userId == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body("로그인이 필요합니다.");
      }

      List<AccountBook> list = accountBookService.getByUserId(userId);
      return ResponseEntity.ok(list);

    } catch (Exception e) {
      log.error("가계부 조회 실패", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(Map.of("error", e.getMessage()));
    }
  }

  @PostMapping("/save")
  public ResponseEntity<?> saveAccountBook(@RequestBody List<AccountBook> transactions,
                                           HttpSession session) {
    try {
      String userId = getUserIdFromSession(session);



      // 일괄 저장
      accountBookService.saveAll(userId, transactions);

      return ResponseEntity.ok(Map.of(
          "success", true,
          "message", transactions.size() + "건의 내역이 저장되었습니다.",
          "count", transactions.size()
      ));

    } catch (Exception e) {
      log.error("가계부 저장 실패", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(Map.of(
              "success", false,
              "message", "저장 실패: " + e.getMessage()
          ));
    }
  }

  @PutMapping("/update")
  public ResponseEntity<?> updateAccountBook(@RequestBody AccountBook dto,
                                             HttpSession session) {
    try {
      String userId = getUserIdFromSession(session);

      if (userId == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body("로그인이 필요합니다.");
      }

      accountBookService.update(userId, dto);

      return ResponseEntity.ok(Map.of(
          "success", true,
          "message", "수정이 완료되었습니다."
      ));

    } catch (Exception e) {
      log.error("가계부 수정 실패", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(Map.of(
              "success", false,
              "message", e.getMessage()
          ));
    }
  }

  @DeleteMapping("/delete/{id}")
  public ResponseEntity<?> deleteAccountBook(@PathVariable Long id,
                                             HttpSession session) {
    try {
      String userId = getUserIdFromSession(session);

      if (userId == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body("로그인이 필요합니다.");
      }

      accountBookService.delete(userId, id);

      return ResponseEntity.ok(Map.of(
          "success", true,
          "message", "삭제가 완료되었습니다."
      ));

    } catch (Exception e) {
      log.error("가계부 삭제 실패", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(Map.of(
              "success", false,
              "message", e.getMessage()
          ));
    }
  }

}

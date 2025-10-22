package edu.sm.app.service;

import edu.sm.app.dto.AccountBook;
import edu.sm.app.repository.AccountBookRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class AccountBookService {

  private final AccountBookRepository repository;

  // 단건 저장
  @Transactional
  public void save(String userId, AccountBook dto) {
    dto.setUserId(userId);
    repository.insert(dto);
    log.info("가계부 저장: userId={}, date={}, amount={}",
        userId, dto.getTransactionDate(), dto.getAmount());
  }

  // 일괄 저장
  @Transactional
  public void saveAll(String userId, List<AccountBook> dtoList) {
    dtoList.forEach(dto -> dto.setUserId(userId));
    repository.insertBatch(dtoList);
    log.info("가계부 일괄 저장: userId={}, count={}", userId, dtoList.size());
  }

  // 조회
  public List<AccountBook> getByUserId(String userId) {
    return repository.selectByUserId(userId);
  }

  // 수정
  @Transactional
  public void update(String userId, AccountBook dto) {
    dto.setUserId(userId);
    int updated = repository.update(dto);
    if (updated == 0) {
      throw new RuntimeException("수정 실패: 해당 데이터가 없거나 권한이 없습니다.");
    }
    log.info("가계부 수정: id={}, userId={}", dto.getId(), userId);
  }

  // 삭제
  @Transactional
  public void delete(String userId, Long id) {
    int deleted = repository.delete(id, userId);
    if (deleted == 0) {
      throw new RuntimeException("삭제 실패: 해당 데이터가 없거나 권한이 없습니다.");
    }
    log.info("가계부 삭제: id={}, userId={}", id, userId);
  }

}

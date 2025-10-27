package edu.sm.app.repository;

import edu.sm.app.dto.AccountBook;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
@Mapper
public interface AccountBookRepository {

  // 단건 삽입
  @Insert("INSERT INTO accountbook (user_id, transaction_date, category, amount, type, memo) " +
      "VALUES (#{userId}, #{transactionDate}::date, #{category}, #{amount}, #{type}, #{memo})")
  @Options(useGeneratedKeys = true, keyProperty = "id")
  void insert(AccountBook accountBook);

  // 일괄 삽입
  @Insert("<script>" +
      "INSERT INTO accountbook (user_id, transaction_date, category, amount, type, memo) VALUES " +
      "<foreach collection='list' item='item' separator=','>" +
      "(#{item.userId}, #{item.transactionDate}::date, #{item.category}, #{item.amount}, #{item.type}, #{item.memo})" +
      "</foreach>" +
      "</script>")
  void insertBatch(@Param("list") List<AccountBook> list);

  // 사용자별 조회
  @Select("SELECT id, user_id as userId, transaction_date as transactionDate, " +
      "category, amount, type, memo, created_at as createdAt " +
      "FROM accountbook WHERE user_id = #{userId} " +
      "ORDER BY transaction_date DESC, created_at DESC")
  List<AccountBook> selectByUserId(String userId);

  // 수정
  @Update("UPDATE accountbook SET " +
      "transaction_date = #{transactionDate}::date, " +
      "category = #{category}, " +
      "amount = #{amount}, " +
      "type = #{type}, " +
      "memo = #{memo} " +
      "WHERE id = #{id} AND user_id = #{userId}")
  int update(AccountBook accountBook);

  // 삭제
  @Delete("DELETE FROM accountbook WHERE id = #{id} AND user_id = #{userId}")
  int delete(@Param("id") Long id, @Param("userId") String userId);
}

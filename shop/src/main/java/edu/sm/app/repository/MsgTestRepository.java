package edu.sm.app.repository;

import edu.sm.app.dto.MsgTest;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface MsgTestRepository extends SmRepository<MsgTest, Integer> {

    @Insert("INSERT INTO msg (sendid, receiveid, content1, rdate) " +
            "VALUES (#{sendid}, #{receiveid}, #{content1}, CURRENT_TIMESTAMP)")
    @Options(useGeneratedKeys = true, keyProperty = "msgId", keyColumn = "msg_id")
    void insert(MsgTest msgTest) throws Exception;

    @Update("UPDATE msg SET content1=#{content1} WHERE msg_id=#{msgId}")
    void update(MsgTest msgTest) throws Exception;

    @Delete("DELETE FROM msg WHERE msg_id=#{id}")
    void delete(Integer id) throws Exception;

    @Select("SELECT * FROM msg ORDER BY rdate DESC")
    List<MsgTest> selectAll() throws Exception;  // List<Msg>로 변경

    @Select("SELECT * FROM msg WHERE msg_id=#{id}")
    MsgTest select(Integer id) throws Exception;

    // 추가 메서드: 두 사용자 간의 최근 메시지 조회
    @Select("SELECT * FROM (" +
            "  SELECT * FROM msg " +
            "  WHERE (sendid = #{custId} AND receiveid = #{adminId}) " +
            "     OR (sendid = #{adminId} AND receiveid = #{custId}) " +
            "  ORDER BY rdate DESC " +
            "  LIMIT #{limit}" +
            ") AS recent_messages " +
            "ORDER BY rdate ASC")
    List<MsgTest> getRecentMessages(@Param("custId") String custId,
                                    @Param("adminId") String adminId,
                                    @Param("limit") int limit) throws Exception;
}

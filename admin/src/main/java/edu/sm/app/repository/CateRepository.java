package edu.sm.app.repository;

import edu.sm.app.dto.Cate;
import edu.sm.app.dto.Marker;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface CateRepository extends SmRepository<Cate, Integer> {
    @Override
    @Insert("INSERT INTO cate VALUES (#{cateId}, #{cateName})")
    void insert(Cate cate) throws Exception;

    @Override
    @Update("UPDATE cate SET cate_name=#{cateName} WHERE cate_id=#{cateId}")
    void update(Cate cate) throws Exception;

    @Override
    @Delete("DELETE FROM cate WHERE cate_id=#{id}")
    void delete(Integer id) throws Exception;

    @Override
    @Select("SELECT * FROM cate")
    List<Cate> selectAll() throws Exception;

    @Override
    @Select("SELECT * FROM cate WHERE cate_id=#{id}")
    Cate select(Integer id) throws Exception;
}

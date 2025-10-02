package edu.sm.app.repository;

import edu.sm.app.dto.Admin;
import edu.sm.app.dto.Cate;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface AdminRepository extends SmRepository<Admin, String> {
    @Override
    @Insert("INSERT INTO admin VALUES (#{adminId}, #{adminPwd},#{adminRole})")
    void insert(Admin admin) throws Exception;

    @Override
    @Update("UPDATE admin SET admin_pwd=#{adminPwd}, admin_role=#{adminRole} WHERE admin_id=#{adminId}")
    void update(Admin admin) throws Exception;

    @Override
    @Delete("DELETE FROM admin WHERE admin_id=#{id}")
    void delete(String id) throws Exception;

    @Override
    @Select("SELECT * FROM admin")
    List<Admin> selectAll() throws Exception;

    @Override
    @Select("SELECT * FROM admin WHERE admin_id=#{id}")
    Admin select(String id) throws Exception;
}

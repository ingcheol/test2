package edu.sm.app.repository;

import edu.sm.app.dto.Content;
import edu.sm.app.dto.Search;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
@Mapper
public interface ContentRepository extends SmRepository<Content, Integer> {
    List<Content> findByAddrAndType(Search search);
}

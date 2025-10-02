package edu.sm.app.service;

import edu.sm.app.dto.Content;
import edu.sm.app.dto.Marker;
import edu.sm.app.dto.Search;
import edu.sm.app.repository.ContentRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@RequiredArgsConstructor
public class ContentService implements SmService<Content, Integer> {

    final ContentRepository contentRepository;

    List<Content> findByAddrAndType(Search search){
        return contentRepository.findByAddrAndType(search);
    }

    @Override
    public void register(Content content) throws Exception {

    }

    @Override
    public void modify(Content content) throws Exception {

    }

    @Override
    public void remove(Integer integer) throws Exception {

    }

    @Override
    public List<Content> get() throws Exception {
        return List.of();
    }

    @Override
    public Content get(Integer integer) throws Exception {
        return null;
    }
}

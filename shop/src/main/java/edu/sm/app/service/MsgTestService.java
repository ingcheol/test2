package edu.sm.app.service;

import edu.sm.app.dto.MsgTest;
import edu.sm.app.repository.MsgTestRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MsgTestService implements SmService<MsgTest, Integer> {

    private final MsgTestRepository msgTestRepository;

    public List<MsgTest> getRecentMessages(String custId, String adminId, int limit) throws Exception {
        return msgTestRepository.getRecentMessages(custId, adminId, limit);
    }

    @Override
    public void register(MsgTest msgTest) throws Exception {
        msgTestRepository.insert(msgTest);
    }

    @Override
    public void modify(MsgTest msgTest) throws Exception {
        msgTestRepository.update(msgTest);
    }

    @Override
    public void remove(Integer id) throws Exception {
        msgTestRepository.delete(id);
    }

    @Override
    public List<MsgTest> get() throws Exception {
        return msgTestRepository.selectAll();
    }

    @Override
    public MsgTest get(Integer id) throws Exception {
        return msgTestRepository.select(id);
    }
}

package edu.sm.app.service;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import edu.sm.app.dto.Cust;
import edu.sm.app.dto.CustSearch;
import edu.sm.app.repository.CustRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustService implements SmService<Cust, String> {

    final CustRepository custRepository;

    @Override
    public void register(Cust cust) throws Exception {
        custRepository.insert(cust);
    }

    @Override
    public void modify(Cust cust) throws Exception {
        custRepository.update(cust);
    }

    @Override
    public void remove(String s) throws Exception {
        custRepository.delete(s);
    }

    @Override
    public List<Cust> get() throws Exception {
        return custRepository.selectAll();
    }

    @Override
    public Cust get(String s) throws Exception {
        return custRepository.select(s);
    }
    public List<Cust> searchCustList(CustSearch custSearch) throws Exception {
        return custRepository.searchCustList(custSearch);
    }
    public Page<Cust> getPage(int pageNo) throws Exception {
        PageHelper.startPage(pageNo, 3); // 3: 한화면에 출력되는 개수
        return custRepository.getpage();
    }
    public Page<Cust> getPageSearch(int pageNo, CustSearch custSearch) throws Exception {
        PageHelper.startPage(pageNo, 3); // 3: 한화면에 출력되는 개수
        return custRepository.getpageSearch(custSearch);
    }
}
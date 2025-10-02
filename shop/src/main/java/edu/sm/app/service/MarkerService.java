package edu.sm.app.service;

import edu.sm.app.dto.Marker;
import edu.sm.app.repository.MarkerRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@RequiredArgsConstructor
public class MarkerService implements SmService<Marker, Integer> {

    final MarkerRepository markerRepository;

    @Override
    public void register(Marker marker) throws Exception {
        markerRepository.insert(marker);
    }

    @Override
    public void modify(Marker marker) throws Exception {
        markerRepository.update(marker);
    }

    @Override
    public void remove(Integer integer) throws Exception {
        markerRepository.delete(integer);
    }

    @Override
    public List<Marker> get() throws Exception {
        return markerRepository.selectAll();
    }

    public List<Marker> findByLoc(int loc) throws Exception {
        return markerRepository.findByLoc(loc);
    }

    @Override
    public Marker get(Integer integer) throws Exception {
        return markerRepository.select(integer);
    }
}













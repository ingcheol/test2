package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/logs")
@Slf4j
public class LogController {

    @Value("${logdir:C:/test2/logs/}")
    private String logDir;

    @GetMapping("/mapclick")
    public ResponseEntity<String> getMapClickLog() {
        try {
            String logPath = logDir + "mapclick.log";
            log.info("Reading log file from: {}", logPath);

            // 로그 파일 읽기
            String content = new String(Files.readAllBytes(Paths.get(logPath)));

            if (content.isEmpty()) {
                return ResponseEntity.ok(""); // 빈 파일
            }

            return ResponseEntity.ok(content);

        } catch (IOException e) {
            log.error("Error reading mapclick.log", e);
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Log file not found or cannot be read");
        }
    }

    @GetMapping("/hotplace")
    public ResponseEntity<Map<String, Object>> getHotPlace() {
        Map<String, Object> result = new HashMap<>();

        try {
            String logPath = logDir + "mapclick.log";
            String content = new String(Files.readAllBytes(Paths.get(logPath)));

            if (content.isEmpty()) {
                result.put("hasHotPlace", false);
                return ResponseEntity.ok(result);
            }

            String[] lines = content.trim().split("\n");
            Map<String, Integer> placeCount = new HashMap<>();
            Map<String, Integer> recentPlaceCount = new HashMap<>();

            LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

            // 전체 데이터와 1시간 내 데이터 분석
            for (String line : lines) {
                String[] parts = line.split(", ");
                if (parts.length >= 3) {
                    String dateStr = parts[0].trim();
                    String place = parts[2].trim();

                    // 전체 카운트
                    placeCount.put(place, placeCount.getOrDefault(place, 0) + 1);

                    // 1시간 내 카운트
                    try {
                        LocalDateTime logTime = LocalDateTime.parse(dateStr, formatter);
                        if (logTime.isAfter(oneHourAgo)) {
                            recentPlaceCount.put(place, recentPlaceCount.getOrDefault(place, 0) + 1);
                        }
                    } catch (Exception e) {
                        log.warn("날짜 파싱 오류: " + dateStr);
                    }
                }
            }

            // Top 3 인기 장소 추출
            List<Map<String, Object>> top3Places = placeCount.entrySet().stream()
                    .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                    .limit(3)
                    .map(entry -> {
                        Map<String, Object> placeInfo = new HashMap<>();
                        placeInfo.put("name", entry.getKey());
                        placeInfo.put("count", entry.getValue());
                        return placeInfo;
                    })
                    .collect(Collectors.toList());

            // 1시간 내 핫플레이스 (1위만)
            Map.Entry<String, Integer> recentTop = recentPlaceCount.entrySet().stream()
                    .max(Map.Entry.comparingByValue())
                    .orElse(null);

            result.put("hasHotPlace", true);
            result.put("top3Places", top3Places);

            if (recentTop != null && recentTop.getValue() >= 3) {
                Map<String, Object> recentHotPlace = new HashMap<>();
                recentHotPlace.put("name", recentTop.getKey());
                recentHotPlace.put("count", recentTop.getValue());
                result.put("recentHotPlace", recentHotPlace);
                result.put("showRecent", true);
            } else {
                result.put("showRecent", false);
            }

            return ResponseEntity.ok(result);

        } catch (IOException e) {
            log.error("Error reading log file", e);
            result.put("hasHotPlace", false);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }
}

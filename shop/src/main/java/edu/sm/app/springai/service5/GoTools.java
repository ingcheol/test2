package edu.sm.app.springai.service5;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class GoTools {

    @Tool(description = "사용자가 원하는 화면의 URL 정보을 제공 합니다.")
    public String getMovieListByUserId(
            @ToolParam(description = "화면", required = true) String view) {
        log.info(view);
        //데이터베이스에서 검색해서 가져온 내용
        Map<String, String> views = new ConcurrentHashMap<>();

        views.put("로그인화면", "/login");
        views.put("상품화면", "/items");

        String result =  views.keySet().stream().filter(s -> s.equals(view)).findFirst().get();
        log.info(views.get(result));

        return views.get(result);
    }

    @Tool(description = "주어진 쟝르의 추천 영화 목록을 제공합니다.", returnDirect = true)
    public List<String> recommendMovie(

            @ToolParam(description = "쟝르", required = true) String genre) {
        log.info(genre);

        //데이터베이스에서 검색해서 가져온 내용
        List<String> movies = List.of("크레이븐", "베놈", "메이드");
        return movies;
    }

}
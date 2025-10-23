package edu.sm.app.springai.service5;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.model.ToolContext;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@Slf4j
public class RecommendMovieTools {

    @Tool(description = "사용자가 관람한 영화 목록을 제공합니다.")
    public List<String> getMovieListByUserId(ToolContext toolContext) {
        String userId = (String) toolContext.getContext().get("custid");

        log.info(userId);
        //데이터베이스에서 검색해서 가져온 내용
        List<String> movies = List.of(
                "인셉션","로보캅","터미네이터","아바타","타이타닉"
        );
        return movies;
    }

    @Tool(description = "주어진 영화의  감독의 추천 영화 목록을 제공합니다.", returnDirect = true)
    public List<String> recommendMovie(

            @ToolParam(description = "감독", required = true) String genre) {
        log.info("genre: "+genre);

        //데이터베이스에서 검색해서 가져온 내용
        List<String> movies = List.of("크레이븐", "베놈", "메이드");
        return movies;
    }

}
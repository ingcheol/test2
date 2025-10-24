package edu.sm.app.springai.service4;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Description;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.function.Function;

@Service
@Slf4j
public class TravelToolService {

  private final VectorStore vectorStore;

  public TravelToolService(VectorStore vectorStore) {
    this.vectorStore = vectorStore;
  }

  @Bean
  @Description("특정 지역의 맛집를 추천합니다. 지역명을 입력하면 해당 지역의 인기 맛집 정보를 제공합니다.")
  public Function<TravelRequest, TravelResponse> recommendTourist() {
    return request -> {
      try {
        log.info("맛집 추천 Tool 호출: location={}", request.location());

        SearchRequest searchRequest = SearchRequest.builder()
            .query(request.location() + " 맛집")
            .similarityThreshold(0.5)
            .topK(10)
            .build();

        String recommendations = vectorStore.similaritySearch(searchRequest)
            .stream()
            .map(doc -> doc.getText())
            .reduce("", (a, b) -> a + "\n\n" + b);

        if (StringUtils.hasText(recommendations)) {
          return new TravelResponse(request.location(), recommendations, "success");
        } else {
          return new TravelResponse(
              request.location(),
              request.location() + "의 맛집 정보가 없습니다.",
              "not_found"
          );
        }

      } catch (Exception e) {
        log.error("맛집 추천 실패", e);
        return new TravelResponse(
            request.location(),
            "맛집 추천 중 오류가 발생했습니다.",
            "error"
        );
      }
    };
  }

  @Bean
  @Description("특정 지역의 맛집을 추천합니다. 지역명을 입력하면 해당 지역의 인기 맛집 정보를 제공합니다.")
  public Function<TravelRequest, TravelResponse> recommendRestaurant() {
    return request -> {
      try {
        log.info("맛집 추천 Tool 호출: location={}", request.location());

        SearchRequest searchRequest = SearchRequest.builder()
            .query(request.location() + " 맛집")
            .similarityThreshold(0.3)
            .topK(5)
            .build();

        String recommendations = vectorStore.similaritySearch(searchRequest)
            .stream()
            .map(doc -> doc.getText())
            .reduce("", (a, b) -> a + "\n\n" + b);

        if (StringUtils.hasText(recommendations)) {
          return new TravelResponse(request.location(), recommendations, "success");
        } else {
          return new TravelResponse(
              request.location(),
              request.location() + "의 맛집 정보가 없습니다.",
              "not_found"
          );
        }

      } catch (Exception e) {
        log.error("맛집 추천 실패", e);
        return new TravelResponse(
            request.location(),
            "맛집 추천 중 오류가 발생했습니다.",
            "error"
        );
      }
    };
  }

  public record TravelRequest(
      @Description("맛집 찾을 지역명 (예: 부산, 제주)")
      String location
  ) {}

  public record TravelResponse(
      String location,
      String recommendations,
      String status
  ) {}
}

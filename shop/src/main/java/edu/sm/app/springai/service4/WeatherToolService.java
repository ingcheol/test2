package edu.sm.app.springai.service4;

import edu.sm.util.WeatherUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Description;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.function.Function;

@Service
@Slf4j
@RequiredArgsConstructor
public class WeatherToolService {

  @Value("${app.key.owkey}")
  private String owkey;

  private final ChatClient.Builder chatClientBuilder;

  @Bean
  @Description("전세계 모든 도시의 현재 날씨와 5일 예보를 조회합니다. 한글 또는 영어 가능")
  public Function<WeatherRequest, WeatherResponse> getWeather() {
    return request -> {
      try {
        String location = request.location().trim();

        String cityName = translateToEnglish(location);

        Object currentResult = WeatherUtil.getWeather2(cityName, owkey);
        if (currentResult == null) {
          return new WeatherResponse(
              location,
              "날씨 API에서 응답이 없습니다.",
              "error"
          );
        }

        Object forecastResult = WeatherUtil.getWeather2Forecast(cityName, owkey);
        String weatherInfo = parseWeatherWithForecast(currentResult, forecastResult);

        return new WeatherResponse(location, weatherInfo, "success");

      } catch (Exception e) {
        log.error("날씨 조회 실패: location={}", request.location(), e);
        return new WeatherResponse(
            request.location(),
            "날씨 정보를 가져올 수 없습니다. 도시명을 확인해주세요.",
            "error"
        );
      }
    };
  }

  private String translateToEnglish(String cityName) {
    if (cityName.matches("^[a-zA-Z\\s]+$")) {
      return cityName;
    }

    try {
      ChatClient chatClient = chatClientBuilder.build();
      String prompt = String.format(
          "다음 도시명을 영어로 변환하세요. 도시 이름만 반환하세요.\n\n도시명: %s",
          cityName
      );

      String englishName = chatClient.prompt()
          .user(prompt)
          .call()
          .content()
          .trim();

      return englishName;

    } catch (Exception e) {
      log.error("도시명 번역 실패: {}", cityName, e);
      return cityName;
    }
  }

  private String parseWeatherWithForecast(Object currentResult, Object forecastResult) {
    try {
      StringBuilder sb = new StringBuilder();

      JSONObject currentJson = (JSONObject) currentResult;

      long timestamp = ((Number) currentJson.get("dt")).longValue();
      LocalDate currentDate = Instant.ofEpochSecond(timestamp)
          .atZone(ZoneId.systemDefault())
          .toLocalDate();

      JSONObject main = (JSONObject) currentJson.get("main");
      double temp = ((Number) main.get("temp")).doubleValue();
      double feelsLike = ((Number) main.get("feels_like")).doubleValue();
      int humidity = ((Number) main.get("humidity")).intValue();

      JSONArray weatherArray = (JSONArray) currentJson.get("weather");
      String description = "";
      if (weatherArray != null && !weatherArray.isEmpty()) {
        JSONObject weather = (JSONObject) weatherArray.get(0);
        description = (String) weather.get("description");
      }

      JSONObject wind = (JSONObject) currentJson.get("wind");
      double windSpeed = ((Number) wind.get("speed")).doubleValue();

      sb.append(String.format(
          "현재 기온: %.1f°C (체감: %.1f°C)\n" +
              "날씨: %s\n" +
              "습도: %d%%\n" +
              "풍속: %.1f m/s\n\n",
          temp, feelsLike, description, humidity, windSpeed
      ));

      if (forecastResult != null) {
        JSONObject forecastJson = (JSONObject) forecastResult;
        JSONArray list = (JSONArray) forecastJson.get("list");

        if (list != null && !list.isEmpty()) {
          sb.append("[앞으로 5일 날씨 예보]\n\n");

          LocalDate lastDate = null;
          int dayCount = 0;

          for (Object item : list) {
            JSONObject forecast = (JSONObject) item;

            long dt = ((Number) forecast.get("dt")).longValue();
            LocalDate date = Instant.ofEpochSecond(dt)
                .atZone(ZoneId.systemDefault())
                .toLocalDate();

            if (date.equals(lastDate)) continue;
            if (date.equals(currentDate)) continue;

            lastDate = date;
            dayCount++;

            if (dayCount > 5) break;

            JSONObject mainForecast = (JSONObject) forecast.get("main");
            double tempMin = ((Number) mainForecast.get("temp_min")).doubleValue();
            double tempMax = ((Number) mainForecast.get("temp_max")).doubleValue();

            JSONArray weatherForecast = (JSONArray) forecast.get("weather");
            String descForecast = "";
            if (weatherForecast != null && !weatherForecast.isEmpty()) {
              JSONObject w = (JSONObject) weatherForecast.get(0);
              descForecast = (String) w.get("description");
            }

            String dateLabel = date.format(DateTimeFormatter.ofPattern("MM월 dd일 (E)"));

            sb.append(String.format(
                "%s: %s, 최저 %.1f°C / 최고 %.1f°C\n",
                dateLabel, descForecast, tempMin, tempMax
            ));
          }
        }
      }

      return sb.toString();

    } catch (Exception e) {
      log.error("날씨 정보 파싱 실패", e);
      return "날씨 정보 파싱 중 오류가 발생했습니다.";
    }
  }

  public record WeatherRequest(
      @Description("날씨를 조회할 나라이름 (한글 또는 영어 가능)")
      String location
  ) {}

  public record WeatherResponse(
      String location,
      String weatherInfo,
      String status
  ) {}
}

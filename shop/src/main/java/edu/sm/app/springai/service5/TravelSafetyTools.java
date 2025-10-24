package edu.sm.app.springai.service5;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Component
@Slf4j
public class TravelSafetyTools {

  @Value("${app.key.travel-safety-key}")
  private String mofakey;

  private final ObjectMapper objectMapper = new ObjectMapper();

//   1. 국가별 여행경보 단계 조회
  @Tool(description = """
        특정 국가의 여행경보 단계를 조회합니다.
        1단계(남색): 여행유의
        2단계(황색): 여행자제  
        3단계(적색): 출국권고
        4단계(흑색): 여행금지
        국가명을 한글로 입력하세요. (예: 일본, 프랑스, 태국, 캄보디아)
        """)
  public String getTravelWarningLevel(
      @ToolParam(description = "조회할 국가명 (한글)", required = true) String countryName
  ) {
    try {
      String encodedCountry = URLEncoder.encode(countryName, StandardCharsets.UTF_8);

      String urlStr = String.format(
          "https://apis.data.go.kr/1262000/TravelAlarmService2/getTravelAlarmList2" +
              "?serviceKey=%s&returnType=JSON&numOfRows=10&pageNo=1&cond[country_nm::EQ]=%s",
          mofakey, encodedCountry
      );

      log.info("여행경보 API 호출: {}", countryName);

      URL url = new URL(urlStr);
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("GET");
      conn.setRequestProperty("Accept", "application/json");

      BufferedReader br = new BufferedReader(
          new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8)
      );

      StringBuilder response = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) {
        response.append(line);
      }
      br.close();
      conn.disconnect();

      // JSON 파싱
      JsonNode root = objectMapper.readTree(response.toString());
      JsonNode itemsNode = root.path("response").path("body").path("items").path("item");

      if (!itemsNode.isArray() || itemsNode.size() == 0) {
        return String.format("'%s' 국가의 여행경보 정보를 찾을 수 없습니다.", countryName);
      }

      StringBuilder result = new StringBuilder();
      for (JsonNode item : itemsNode) {
        int alarmLevel = Integer.parseInt(item.path("alarm_lvl").asText());
        String regionType = item.path("region_ty").asText();
        String remark = item.path("remark").asText();

        String levelText = switch (alarmLevel) {
          case 1 -> "1단계 (남색 - 여행유의)";
          case 2 -> "2단계 (황색 - 여행자제)";
          case 3 -> "3단계 (적색 - 출국권고)";
          case 4 -> "4단계 (흑색 - 여행금지)";
          default -> "정보 없음";
        };

        result.append(String.format("- %s: %s (%s)\n", levelText, regionType, remark));
      }

      int maxLevel = 0;
      for (JsonNode item : itemsNode) {
        int level = Integer.parseInt(item.path("alarm_lvl").asText());
        if (level > maxLevel) maxLevel = level;
      }

      String safetyAdvice = switch (maxLevel) {
        case 1 -> "✅ 일반적인 안전 수칙을 준수하면 여행 가능합니다.";
        case 2 -> "⚠️ 특별한 주의가 필요하며, 불필요한 여행은 자제하시기 바랍니다.";
        case 3 -> "🚨 매우 위험한 상태입니다. 체류 중이라면 즉시 출국하세요.";
        case 4 -> "⛔ 일부 지역은 여행금지입니다. 해당 지역 방문을 절대 금합니다.";
        default -> "";
      };

      result.append(safetyAdvice);
      return result.toString();

    } catch (Exception e) {
      log.error("여행경보 조회 실패 - {}: {}", countryName, e.getMessage(), e);
      return String.format("여행경보 정보를 가져오는 중 오류가 발생했습니다: %s", e.getMessage());
    }
  }

//   2. 특별여행주의보 조회
@Tool(description = "특정 국가의 특별여행주의보를 조회합니다.")
public String getSpecialTravelAlert(
    @ToolParam(description = "조회할 국가명 (한글)", required = true) String countryName
) {
  try {
    String encodedCountry = URLEncoder.encode(countryName, StandardCharsets.UTF_8);

    String urlStr = String.format(
        "https://apis.data.go.kr/1262000/TravelSpecialWarningServiceV3/getTravelSpecialWarningListV3" +
            "?serviceKey=%s&returnType=JSON&numOfRows=10&pageNo=1&cond[country_name::EQ]=%s",
        mofakey, encodedCountry
    );

    URL url = new URL(urlStr);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");

    BufferedReader br = new BufferedReader(
        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8)
    );

    StringBuilder response = new StringBuilder();
    String line;
    while ((line = br.readLine()) != null) {
      response.append(line);
    }
    br.close();
    conn.disconnect();

    JsonNode root = objectMapper.readTree(response.toString());
    String resultCode = root.path("response").path("header").path("resultCode").asText();

    if (!"0".equals(resultCode)) {
      return "특별여행주의보 API 오류가 발생했습니다.";
    }

    JsonNode itemsNode = root.path("response").path("body").path("items").path("item");

    if (!itemsNode.isArray() || itemsNode.size() == 0) {
      return String.format("%s에는 현재 특별여행주의보가 발령되지 않았습니다.", countryName);
    }

    JsonNode data = itemsNode.get(0);

    String splimitPartial = data.path("splimit_partial").asText();
    String splimitNote = data.path("splimit_note").asText();

    if ("null".equals(splimitPartial) || splimitPartial.isEmpty()) {
      return String.format("%s에는 현재 특별여행주의보가 발령되지 않았습니다.", countryName);
    }

    StringBuilder result = new StringBuilder();
    result.append(String.format("⚠️ %s 특별여행주의보 발령 중!\n\n발령 상태: %s\n",
        countryName, splimitPartial));

    if (splimitNote != null && !splimitNote.isEmpty() && !"null".equals(splimitNote)) {
      result.append(String.format("적용 지역: %s\n", splimitNote));
    }

    result.append("\n주의사항: 해당 지역 여행을 자제하고, 현지 상황을 주시하세요.");

    return result.toString();

  } catch (Exception e) {
    log.error("특별경보 조회 실패: {}", e.getMessage());
    return "특별여행주의보 조회 중 오류가 발생했습니다.";
  }
}

//   3. 국가별 안전공지 조회
  @Tool(description = """
        특정 국가의 최근 안전공지를 조회합니다.
        시위, 범죄, 질병, 재난 등 실시간 안전 정보를 제공합니다.
        """)
  public String getSafetyNotices(
      @ToolParam(description = "조회할 국가명 (한글)", required = true) String countryName
  ) {
    try {
      String encodedCountry = URLEncoder.encode(countryName, StandardCharsets.UTF_8);

      String urlStr = String.format(
          "https://apis.data.go.kr/1262000/CountrySafetyService6/getCountrySafetyList6" +
              "?serviceKey=%s&returnType=JSON&numOfRows=5&pageNo=1&cond[country_nm::EQ]=%s",
          mofakey, encodedCountry
      );

      URL url = new URL(urlStr);
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("GET");

      BufferedReader br = new BufferedReader(
          new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8)
      );

      StringBuilder response = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) {
        response.append(line);
      }
      br.close();
      conn.disconnect();

      JsonNode root = objectMapper.readTree(response.toString());
      String resultCode = root.path("response").path("header").path("resultCode").asText();

      if (!"0".equals(resultCode)) {
        return "API 오류 발생";
      }

      JsonNode itemsNode = root.path("response").path("body").path("items").path("item");

      if (!itemsNode.isArray() || itemsNode.size() == 0) {
        return String.format("%s에 대한 최근 안전공지가 없습니다.", countryName);
      }

      StringBuilder result = new StringBuilder();
      result.append(String.format("[%s 최근 안전공지 %d건]\n\n",
          countryName, itemsNode.size()));

      int count = 1;
      for (JsonNode item : itemsNode) {
        String title = item.path("title").asText();
        String content = item.path("txt_origin_cn").asText();
        String date = item.path("wrt_dt").asText();

        if (content.length() > 150) {
          content = content.substring(0, 150) + "...";
        }

        result.append(String.format("""
                    %d. [%s] %s
                       %s
                    
                    """, count++, date, title, content));
      }

      result.append("💡 상세 정보는 www.0404.go.kr에서 확인하세요.");
      return result.toString();

    } catch (Exception e) {
      log.error("안전공지 조회 실패: {}", e.getMessage());
      return "안전공지 조회 중 오류가 발생했습니다.";
    }
  }
}

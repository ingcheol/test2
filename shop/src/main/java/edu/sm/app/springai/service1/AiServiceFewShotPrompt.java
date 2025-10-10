package edu.sm.app.springai.service1;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class AiServiceFewShotPrompt {
    private ChatClient chatClient;

    public AiServiceFewShotPrompt(ChatClient.Builder chatClientBuilder) {
        chatClient = chatClientBuilder.build();
    }

    public String fewShotPrompt(String question) {
        String strPrompt = """
        당신은 천안시와 제주도 관광 전문 가이드입니다.
        사용자의 질문에 따라 관광 일정을 JSON 형식으로 제공해주세요.
        
        아래 규칙을 반드시 지켜주세요:
        1. 응답은 순수한 JSON 형식으로만 반환하세요 (마크다운 없이)
        2. 일정은 날짜별로 구성하세요
        3. 각 장소에 시간, 이름, 설명, 팁을 포함하세요
        4. 실제 존재하는 장소만 추천하세요
        5. 당일~2박3일 이내의 일정으로 간결하게 구성하세요
        6. 하루에 4-5개 장소만 추천하세요 (너무 많으면 피곤함)
        
        천안 주요 관광지:
        - 독립기념관: 한국 독립운동 역사 전시관, 무료입장
        - 천안삼거리공원: 흥타령 춤 공연, 천안의 상징
        - 각원사: 청동 좌불상 유명 사찰
        - 성거산: 등산 명소, 전망대
        - 아라리오갤러리: 현대미술 전시관
        - 병천순대거리: 천안 대표 맛집 거리
        - 천안종합터미널시장: 전통시장
        
        제주도 주요 관광지:
        - 성산일출봉: 유네스코 세계자연유산, 일출 명소
        - 한라산: 제주 최고봉, 등산 코스
        - 섭지코지: 드라마 촬영지, 해안 절경
        - 우도: 제주 부속섬, 자전거 여행
        - 만장굴: 용암동굴, 세계자연유산
        - 천지연폭포: 서귀포 3대 폭포
        - 주상절리대: 중문 해안 화산암 절벽
        - 동문시장: 제주 최대 전통시장
        - 흑돼지거리: 제주 대표 맛집 거리
        - 협재해수욕장: 제주 서쪽 에메랄드빛 해변
        - 카멜리아힐: 동백꽃 정원
        
        예시1:
        질문: 천안 당일치기 코스 추천해줘
        
        JSON 응답:
        {
          "title": "천안 당일치기 추천 코스",
          "days": 1,
          "schedule": [
            {
              "date": "1일차",
              "places": [
                {
                  "time": "10:00-12:30",
                  "name": "독립기념관",
                  "description": "한국 독립운동 역사를 배우는 의미있는 시간. 넓은 야외공원과 7개 전시관 관람",
                  "tip": "입장료 무료, 월요일 휴관, 주차 가능"
                },
                {
                  "time": "13:00-14:30",
                  "name": "병천순대거리",
                  "description": "천안의 대표 맛집 거리에서 점심식사. 순대국밥과 아바이순대 추천",
                  "tip": "1인당 8,000-12,000원, 주차 가능"
                },
                {
                  "time": "15:00-17:00",
                  "name": "천안삼거리공원",
                  "description": "천안의 상징적인 장소 산책. 주말에는 흥타령 공연 관람 가능",
                  "tip": "공원 산책 무료, 사진 촬영 명소"
                },
                {
                  "time": "17:30-18:30",
                  "name": "천안역 호두과자 거리",
                  "description": "천안 대표 특산품 호두과자 구매. 선물용으로 좋음",
                  "tip": "여러 브랜드 비교 구매 가능"
                }
              ]
            }
          ]
        }
        
        예시2:
        질문: 천안 1박2일 가족여행 코스 짜줘
        
        JSON 응답:
        {
          "title": "천안 1박2일 가족여행 코스",
          "days": 2,
          "schedule": [
            {
              "date": "1일차",
              "places": [
                {
                  "time": "10:00-13:00",
                  "name": "독립기념관",
                  "description": "아이들과 함께 한국 독립운동 역사 학습. 넓은 야외공원에서 뛰어놀기",
                  "tip": "도시락 준비하면 야외에서 피크닉 가능"
                },
                {
                  "time": "13:30-15:00",
                  "name": "병천순대거리 점심",
                  "description": "가족 단위 식사하기 좋은 순대국밥 맛집",
                  "tip": "아이 메뉴도 있음, 주차 편리"
                },
                {
                  "time": "15:30-17:30",
                  "name": "각원사",
                  "description": "청동 좌불상 구경과 사찰 체험. 아이들 문화 체험",
                  "tip": "경내 입장 무료, 조용히 관람"
                },
                {
                  "time": "18:00-",
                  "name": "호텔 체크인 및 저녁",
                  "description": "천안 시내 호텔 체크인 후 휴식",
                  "tip": "천안역 근처 호텔 추천"
                }
              ]
            },
            {
              "date": "2일차",
              "places": [
                {
                  "time": "09:00-11:30",
                  "name": "성거산 등산",
                  "description": "가벼운 등산 코스. 정상 전망대에서 천안 시내 조망",
                  "tip": "편한 신발 착용, 물 준비"
                },
                {
                  "time": "12:00-13:30",
                  "name": "천안종합터미널시장",
                  "description": "전통시장에서 점심 먹고 구경하기",
                  "tip": "다양한 먹거리와 볼거리"
                },
                {
                  "time": "14:00-15:30",
                  "name": "천안삼거리공원",
                  "description": "마지막 산책과 사진 촬영",
                  "tip": "흥타령 동상과 기념 사진"
                }
              ]
            }
          ]
        }
        
        예시3:
        질문: 제주도 2박3일 여행 코스 추천해줘
        
        JSON 응답:
        {
          "title": "제주도 2박3일 힐링 여행",
          "days": 3,
          "schedule": [
            {
              "date": "1일차",
              "places": [
                {
                  "time": "10:00-11:00",
                  "name": "제주공항 도착 및 렌터카 픽업",
                  "description": "제주공항에서 렌터카를 받고 여행 시작",
                  "tip": "사전 렌터카 예약 필수, 국제면허증 또는 한국 면허증 지참"
                },
                {
                  "time": "11:30-13:30",
                  "name": "성산일출봉",
                  "description": "유네스코 세계자연유산. 화산 분화구 정상까지 등반하며 제주 동쪽 바다 전망",
                  "tip": "입장료 5,000원, 등반 30분 소요, 편한 신발 필수"
                },
                {
                  "time": "14:00-15:30",
                  "name": "섭지코지 해안산책",
                  "description": "드라마 촬영지로 유명한 해안 절경. 유채꽃 명소",
                  "tip": "무료 입장, 봄 유채꽃 시즌 추천"
                },
                {
                  "time": "16:00-18:00",
                  "name": "우도 페리 관광",
                  "description": "제주 부속섬 우도에서 자전거 투어",
                  "tip": "페리 왕복 8,500원, 자전거 대여 1만원, 땅콩아이스크림 필수"
                },
                {
                  "time": "19:00-",
                  "name": "서귀포 숙소 체크인 및 흑돼지 저녁",
                  "description": "서귀포 시내 호텔 체크인 후 흑돼지 맛집 방문",
                  "tip": "흑돼지 1인분 15,000-20,000원"
                }
              ]
            },
            {
              "date": "2일차",
              "places": [
                {
                  "time": "09:00-12:00",
                  "name": "한라산 등산",
                  "description": "제주 최고봉 한라산 등반. 성판악 코스 추천",
                  "tip": "편한 등산화 필수, 도시락 준비, 입산시간 제한 확인"
                },
                {
                  "time": "13:00-14:30",
                  "name": "점심 및 휴식",
                  "description": "제주 고기국수 또는 제주 흑돼지",
                  "tip": "고기국수 7,000-9,000원"
                },
                {
                  "time": "15:00-17:00",
                  "name": "주상절리대",
                  "description": "중문 해안의 장엄한 화산암 절벽 경관",
                  "tip": "입장료 2,000원, 일몰 시간 방문 추천"
                },
                {
                  "time": "17:30-19:00",
                  "name": "천지연폭포",
                  "description": "서귀포 3대 폭포 중 하나. 야간 조명이 아름다움",
                  "tip": "입장료 2,000원, 산책로 정비 잘 되어있음"
                },
                {
                  "time": "19:30-",
                  "name": "서귀포 칠십리 맛집거리",
                  "description": "해산물 맛집과 카페가 모여있는 거리",
                  "tip": "회, 전복죽, 갈치조림 추천"
                }
              ]
            },
            {
              "date": "3일차",
              "places": [
                {
                  "time": "09:00-11:00",
                  "name": "협재해수욕장",
                  "description": "제주 서쪽의 에메랄드빛 해변. 비양도 전망",
                  "tip": "무료, 여름 해수욕 가능, 주차 편리"
                },
                {
                  "time": "11:30-13:00",
                  "name": "카멜리아힐",
                  "description": "동백꽃과 다양한 꽃들의 정원. 포토존 많음",
                  "tip": "입장료 8,000원, 겨울-봄 동백꽃 시즌 최고"
                },
                {
                  "time": "13:30-15:00",
                  "name": "동문시장 점심 및 쇼핑",
                  "description": "제주 최대 전통시장. 제주 특산물 쇼핑",
                  "tip": "회, 고등어구이, 제주 과일 저렴"
                },
                {
                  "time": "15:30-17:00",
                  "name": "제주공항 출발",
                  "description": "렌터카 반납 후 귀가",
                  "tip": "출발 2시간 전 공항 도착 권장"
                }
              ]
            }
          ]
        }
        
        현재 질문: %s
        
        위 예시처럼 JSON 형식으로만 답변해주세요. 추가 설명은 포함하지 마세요.""".formatted(question);

        Prompt prompt = Prompt.builder()
                .content(strPrompt)
                .build();

        String tourismSchedule = chatClient.prompt(prompt)
                .options(ChatOptions.builder()
                        .temperature(0.7)
                        .maxTokens(2000)
                        .build())
                .call()
                .content();

        // JSON 응답만 추출 (앞뒤 불필요한 텍스트 제거)
        tourismSchedule = extractJsonFromResponse(tourismSchedule);

        return tourismSchedule;
    }

    private String extractJsonFromResponse(String response) {
        // 마크다운 제거
        response = response.trim()
                .replaceAll("```json\\s*", "")
                .replaceAll("```\\s*", "");

        // JSON 시작/끝 찾기
        int jsonStart = response.indexOf("{");
        int jsonEnd = response.lastIndexOf("}");

        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
            response = response.substring(jsonStart, jsonEnd + 1);
        }

        return response;
    }
}
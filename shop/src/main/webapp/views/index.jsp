<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <title>Bootstrap 4 Website Example</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=8ebb7e444a8cd5d1f3bbc02bbacb744a&libraries=services"></script>
    <%-- highchart lib   --%>
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/modules/wordcloud.js"></script>
    <script src="https://code.highcharts.com/highcharts-3d.js"></script>
    <script src="https://code.highcharts.com/modules/cylinder.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>
    <script src="https://code.highcharts.com/modules/export-data.js"></script>
    <script src="https://code.highcharts.com/modules/accessibility.js"></script>
    <script src="https://code.highcharts.com/themes/adaptive.js"></script>
    <script src="https://code.highcharts.com/modules/non-cartesian-zoom.js"></script>
    <script src="https://code.highcharts.com/modules/data.js"></script>

    <%-- Web Socket Lib --%>
    <script src="/webjars/sockjs-client/sockjs.min.js"></script>
    <script src="/webjars/stomp-websocket/stomp.min.js"></script>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }

        /* Very Top Bar */
        .very-top-bar {
            background: #f8f9fa;
            padding: 10px 20px;
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            border-bottom: 1px solid #e0e0e0;
        }

        .very-top-bar a {
            color: #333;
            text-decoration: none;
            font-size: 14px;
            padding: 5px 15px;
            border: 1px solid #ddd;
            border-radius: 20px;
            transition: all 0.3s;
        }

        .very-top-bar a:hover {
            background: #333;
            color: white;
            border-color: #333;
        }

        /* Top Bar */
        .top-bar-wrap {
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .mobile-wrap {
            padding: 15px 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo img {
            height: 50px;
        }

        #mobile-menu-toggle {
            background: #333;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            display: none;
        }

        /* Top Menu */
        #top-nav-wrap {
            background: #2c3e50;
        }

        .top-menu-list {
            list-style: none;
            display: flex;
            justify-content: center;
            padding: 0;
            margin: 0;
        }

        .menu-item {
            position: relative;
        }

        .menu-item > a {
            display: block;
            padding: 20px 30px;
            color: white;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s;
        }

        .menu-item > a:hover {
            background: rgba(255,255,255,0.1);
        }

        /* Mega Menu */
        .mega-nav {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            background: white;
            width: 800px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            z-index: 1000;
            padding: 30px;
        }

        .menu-item:hover .mega-nav {
            display: block;
        }

        .mega-nav-top-nav {
            margin-bottom: 20px;
        }

        .mega-nav-top-nav .h2 {
            font-size: 24px;
            font-weight: 700;
            color: #333;
        }

        /* Tabs */
        .tabs-nav {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 2px solid #eee;
        }

        .tabs-nav button {
            padding: 10px 20px;
            background: none;
            border: none;
            color: #666;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }

        .tabs-nav button:hover,
        .tabs-nav button[aria-selected="true"] {
            color: #2c3e50;
            border-bottom: 2px solid #2c3e50;
        }

        /* State Boxes */
        .state-boxes {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            max-height: 400px;
            overflow-y: auto;
        }

        .state-box {
            text-decoration: none;
            transition: transform 0.3s;
        }

        .state-box:hover {
            transform: translateY(-5px);
        }

        .thumb-wrap {
            width: 100%;
            height: 120px;
            overflow: hidden;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .thumb-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .state-box-title {
            font-size: 14px;
            font-weight: 600;
            color: #333;
            text-align: center;
        }

        /* Hero Banner */
        .hero {
            position: relative;
            height: 600px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .paralax-wrap {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }

        .paralax-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.4);
            z-index: 1;
        }

        .header-content-wrap {
            position: relative;
            z-index: 2;
            text-align: center;
            padding: 20px;
        }

        .header-content h1 {
            font-size: 5rem;
            font-weight: 900;
            color: white;
            text-transform: uppercase;
            letter-spacing: 3px;
            margin-bottom: 30px;
            text-shadow: 3px 3px 6px rgba(0, 0, 0, 0.5);
            animation: fadeInUp 1s ease-out;
        }

        .ai-title {
            color: white;
            font-size: 1.3rem;
            margin-bottom: 20px;
            animation: fadeInUp 1s ease-out 0.3s both;
        }

        .buttons-wrap-inner {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            justify-content: center;
            animation: fadeInUp 1s ease-out 0.6s both;
        }

        .button--nearwhite {
            background: white;
            color: #333;
            padding: 15px 30px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .button--nearwhite:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(255, 255, 255, 0.4);
            color: #333;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* User Menu */
        .buttons-wrap {
            padding: 10px 20px;
            background: white;
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            align-items: center;
        }

        .buttons-wrap a {
            color: #333;
            text-decoration: none;
            padding: 8px 20px;
            border-radius: 20px;
            border: 1px solid #ddd;
            transition: all 0.3s;
        }

        .buttons-wrap a:hover {
            background: #2c3e50;
            color: white;
            border-color: #2c3e50;
        }

        /* Main Container */
        .main-container {
            min-height: 60vh;
            padding: 30px 0;
        }

        /* Footer */
        .footer {
            background: #2c3e50;
            color: white;
            padding: 30px 0;
            text-align: center;
        }

        /* Responsive */
        @media (max-width: 768px) {
            #mobile-menu-toggle {
                display: block;
            }

            #top-nav-wrap {
                display: none;
            }

            .top-menu-list {
                flex-direction: column;
            }

            .mega-nav {
                width: 100%;
                position: static;
            }

            .state-boxes {
                grid-template-columns: repeat(2, 1fr);
            }

            .header-content h1 {
                font-size: 3rem;
            }

            .buttons-wrap-inner {
                flex-direction: column;
            }
        }

        /* Tab Panel Hidden by Default */
        .tab-panel {
            display: none;
        }

        .tab-panel.is-active {
            display: block;
        }
    </style>

<div id="top-bar" class="is-top"><div class="very-top-bar">
    <a href="<c:url value="/register"/>" data-text="회원가입" class="has-icon has-icon--before has-icon--visas has-icon--bg-light has-icon--bordered">회원가입</a>
    <a href="<c:url value="/login"/>" data-text="로그인" class="has-icon has-icon--before has-icon--suitcase has-icon--bg-light has-icon--bordered">로그인</a>
</div>
    <div id="menu-background" style="display: none;"></div>
    <div class="top-bar-wrap">
        <div id="top-nav-wrap" aria-hidden="false" style="display: flex;">
            <nav id="top-menu" aria-label="Primary navigation" aria-hidden="true">
                <ul class="top-menu-list">
                    <li class="menu-item menu-item-type-post_type menu-item-object-page menu-item-60">
                        <a href="<c:url value="/"/>" data-text="home">홈</a>
                    </li>
                    <li class="menu-item has-sub-menu">
                        <a href="javascript:void(0);" data-text="map" aria-expanded="false" aria-controls="submenu-1">지도</a>
                        <div class="mega-nav" id="submenu-1">
                            <div class="tabs-container">
                                <div class="tabs-content">
                                    <div class="tab-panel fold-wrap lg is-active" role="tabpanel" id="panel-states" aria-labelledby="tab-1">
                                        <div class="state-boxes">
                                            <a href="<c:url value="/map/map1"/>" class="state-box">
                                                <div class="thumb-wrap">
                                                    <img src="<c:url value='/img/cheonan.jpg'/>" alt="천안시">
                                                </div>
                                                <p class="h4 uppercase state-box-title">천안시</p>
                                            </a>
                                            <a href="https://americathebeautiful.com/ko/destinations/alaska/" class="state-box">
                                                <div class="thumb-wrap">
                                                    <img src="<c:url value='/img/jeju.jpg'/>" alt="제주도">
                                                </div>
                                                <p class="h4 uppercase state-box-title">제주도</p>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </li>
                    <li class="menu-item menu-item-type-post_type menu-item-object-page menu-item-59">
                        <a href="<c:url value="chart"/>" data-text="chart">차트</a>
                    </li>
                    <li class="menu-item menu-item-type-post_type menu-item-object-page menu-item-61">
                        <a href="<c:url value="/chat"/>" data-text="chat">채팅</a>
                    </li>
                </ul>
            </nav>
    </div>
<header id="header" class="hero" role="banner" aria-label="Main introduction with background image">
    <div class="paralax-wrap" style="transform: translateY(0px);">
        <img id="header-image" class="to-be-loaded loaded" src="https://americathebeautiful.com/wp-content/uploads/2025/09/AdobeStock_660675796-scaled.jpg" alt="" aria-hidden="true" style="position:absolute;" loading="lazy">
    </div>
    <div class="header-content-wrap fold-flex-sm-up align-items-center justify-content-center">
        <div class="header-content fold-wrap lg padded">
            <h1 class="extra color-nearwhite animating-text --200 mg-bottom-x2 is-animated" data-wait-for="#header-image">
  <span class="word-wrapper">
    <span class="word animate">대동여지도</span>
  </span>
            </h1>
            <div class="buttons-wrap">
                <p class="ai-title animating-element animating-element--fadeUp --200 animate" data-wait-for="#header-image">여행 아이디어를 얻으세요</p>
                <div class="fold-flex gapped buttons-wrap-inner animating-element animating-element--fadeUp --400 animate">
                    <a href="javascript:void(0)" class="ai-title ai-title--dark button button--big button--nearwhite mg-bottom" id="mindtrip-hero-button-1" data-prompt="Where can I find scenic overlooks in U.S. parks?" data-hint="" data-wait-for="#header-image">놀라운 전망을 보여주세요.</a> <a href="javascript:void(0)" class="ai-title ai-title--dark button button--big button--nearwhite mg-bottom" id="mindtrip-hero-button-2" data-prompt="What are some of the top award-winning restaurants in the USA?" data-hint="" data-wait-for="#header-image">버킷리스트 레스토랑을 찾아보세요.</a> <a href="javascript:void(0)" class="ai-title ai-title--dark button button--big button--nearwhite mg-bottom" id="mindtrip-hero-button-3" data-prompt="What are some family-friendly road trips in the USA?" data-hint="" data-wait-for="#header-image">가족과 함께하는 로드 트립을 계획하세요.</a> <a href="javascript:void(0)" class="ai-title ai-title--dark button button--big button--nearwhite mg-bottom" id="mindtrip-hero-button-4" data-prompt=" What U.S. cities have the most exciting art scenes?" data-hint="" data-wait-for="#header-image">최고의 예술 여행지를 찾아보세요.</a>
                </div>
            </div>
        </div>
    </div>
</header>
<div style="position: absolute; top: 300px; height: 1px; pointer-events: none;"></div>
<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', () => {
        const mt_buttons = document.querySelectorAll('[id^="mindtrip-hero-button-"][data-prompt]');
        mt_buttons.forEach(prompt => {
            if (prompt.dataset.prompt !== '') {
                prompt.addEventListener('click', () => {
                    window.mindtrip.showFrame('', {prompt: prompt.dataset.prompt, hint: prompt.dataset.hint});
                })
            }
        })
    })
</script>
    </div>
</div>
<body>
<div id="top-bar" class="is-top">
    <div class="very-top-bar">
        <a href="<c:url value="/register"/>" data-text="회원가입">회원가입</a>
        <a href="<c:url value="/login"/>" data-text="로그인">로그인</a>
    </div>
    <div id="menu-background" style="display: none;"></div>
    <div class="top-bar-wrap">
        <div id="top-nav-wrap" aria-hidden="false" style="display: flex;">
            <nav id="top-menu" aria-label="Primary navigation">
                <ul class="top-menu-list">
                    <li><a href="<c:url value="/"/>">홈</a></li>
                    <li><a href="<c:url value="/map/map1"/>">지도</a></li>
                    <li><a href="<c:url value="/chart"/>">차트</a></li>
                    <li><a href="<c:url value="/chat"/>">채팅</a></li>
                </ul>
            </nav>
        </div>
    </div>
</div>

<div class="container-fluid" style="margin-top: 20px;">
    <div class="row">
        <c:if test="${left != null}">
            <jsp:include page="${left}.jsp"/>
        </c:if>
        <c:if test="${center != null}">
            <jsp:include page="${center}.jsp"/>
        </c:if>
    </div>
</div>
</body>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- jQuery 먼저 로드 -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
  #container {
    overflow: hidden;
    height: 1000px;
    position: relative;
    margin: 150px auto;
    max-width: 2500px;
    border-radius: 15px;
    box-shadow: 0 8px 25px rgba(0,0,0,0.2);
  }

  #mapWrapper {
    width: 100%;
    height: 100%;
    z-index: 1;
  }

  #map1 {
    width: 100%;
    height: 100%;
  }
  #rvWrapper {width:50%; height:100%; top:0; right:0; position:absolute; z-index:0;}
  #container.view_roadview #mapWrapper {width: 50%;}

  #roadviewControl {
    position:absolute; top:5px; left:5px; width:42px; height:42px; z-index: 1; cursor: pointer;
    background: url(https://t1.daumcdn.net/localimg/localimages/07/2018/pc/common/img_search.png) 0 -450px no-repeat;
  }
  #roadviewControl.active {background-position:0 -350px;}

  #close {
    position: absolute; padding: 4px; top: 5px; left: 5px; cursor: pointer;
    background: #fff; border-radius: 4px; border: 1px solid #c8c8c8; box-shadow: 0px 1px #888;
  }
  #close .img {
    display: block;
    background: url(https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/rv_close.png) no-repeat;
    width: 14px; height: 14px;
  }

  #routeInfo {
    position: absolute;
    top: 70px;
    left: 10px;
    background: white;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    z-index: 10;
    min-width: 300px;
    max-height: 500px;
    overflow-y: auto;
    display: none;
  }

  #routeInfo.active {
    display: block;
  }

  #routeInfo h4 {
    margin: 0 0 10px 0;
    font-size: 16px;
    color: #333;
    border-bottom: 2px solid #007bff;
  }

  #routeInfo .route-step {
    margin: 10px 0;
    background: #f8f9fa;
    border-radius: 5px;
    border-left: 4px solid #007bff;
  }

  #routeInfo .route-step.active {
    background: #e7f3ff;
    border-left-color: #0056b3;
  }

  #routeInfo .step-title {
    font-weight: bold;
    color: #333;
    margin-bottom: 5px;
  }

  #routeInfo .step-info {
    font-size: 13px;
    color: #666;
    margin: 3px 0;
  }

  #routeInfo .total-info {
    background: #007bff;
    color: white;
    padding: 12px;
    border-radius: 5px;
    margin-top: 10px;
    text-align: center;
    font-weight: bold;
  }
</style>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f37b6c5eb063be1a82888e664e204d6d&libraries=services,drawing,clusterer"></script>
<script src="https://cdn.jsdelivr.net/npm/@kakao/maps-clusterer@1.0.9/dist/kakao.maps.clusterer.min.js"></script>
<script>
  let map1 = {
    addr: null,
    map: null,
    overlayOn: false,
    container: null,
    rv: null,
    rvClient: null,

    roadviewMarker: null,
    currentLocationMarker: null,
    jejuMarker: null,
    planeMarker: null,
    boatMarker: null,
    airportMarker: null,
    jejuAirportMarker: null,
    portMarker: null,
    jejuPortMarker: null,
    polylines: [],
    touristMarkers: [],
    touristOverlays: [],
    activeOverlay: null,

    currentPosition: null,
    jejuPosition: null,
    gimpoAirport: null,
    jejuAirport: null,
    mokpoPort: null,
    jejuPort: null,

    init: function () {
      this.container = document.getElementById('container');

      // 현재 위치 마커 - 빨간색으로 변경
      const currentMarkerImageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png';
      const currentImageSize = new kakao.maps.Size(64, 69);
      const currentImageOption = {offset: new kakao.maps.Point(27, 69)};
      const currentMarkerImage = new kakao.maps.MarkerImage(currentMarkerImageSrc, currentImageSize, currentImageOption);
      this.currentLocationMarker = new kakao.maps.Marker({
        image: currentMarkerImage,
        title: '현재 위치'
      });

      const redMarkerImageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png';
      const redImageSize = new kakao.maps.Size(64, 69);
      const redImageOption = {offset: new kakao.maps.Point(27, 69)};
      const redMarkerImage = new kakao.maps.MarkerImage(redMarkerImageSrc, redImageSize, redImageOption);
      this.jejuMarker = new kakao.maps.Marker({
        image: redMarkerImage,
        title: '제주도'
      });

      const planeImageSrc = '/img/air.png';
      const planeImageSize = new kakao.maps.Size(40, 40);
      const planeImageOption = {offset: new kakao.maps.Point(20, 20)};
      const planeMarkerImage = new kakao.maps.MarkerImage(planeImageSrc, planeImageSize, planeImageOption);
      this.planeMarker = new kakao.maps.Marker({
        image: planeMarkerImage,
        title: '비행기'
      });

      const boatImageSrc = '/img/sea.png';
      const boatImageSize = new kakao.maps.Size(40, 40);
      const boatImageOption = {offset: new kakao.maps.Point(20, 20)};
      const boatMarkerImage = new kakao.maps.MarkerImage(boatImageSrc, boatImageSize, boatImageOption);
      this.boatMarker = new kakao.maps.Marker({
        image: boatMarkerImage,
        title: '배'
      });

      const pointImageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_number_green.png';
      const pointImageSize = new kakao.maps.Size(36, 37);
      const airportImageOption = {spriteSize: new kakao.maps.Size(36, 691), spriteOrigin: new kakao.maps.Point(0, 36)};
      const airportMarkerImage = new kakao.maps.MarkerImage(pointImageSrc, pointImageSize, airportImageOption);

      const portImageOption = {spriteSize: new kakao.maps.Size(36, 691), spriteOrigin: new kakao.maps.Point(0, 72)};
      const portMarkerImage = new kakao.maps.MarkerImage(pointImageSrc, pointImageSize, portImageOption);

      this.airportMarker = new kakao.maps.Marker({ image: airportMarkerImage, title: '김포공항' });
      this.jejuAirportMarker = new kakao.maps.Marker({ image: airportMarkerImage, title: '제주공항' });
      this.portMarker = new kakao.maps.Marker({ image: portMarkerImage, title: '목포항' });
      this.jejuPortMarker = new kakao.maps.Marker({ image: portMarkerImage, title: '제주항' });

      this.jejuPosition = new kakao.maps.LatLng(33.507548, 126.493487);
      this.gimpoAirport = new kakao.maps.LatLng(37.5583, 126.7906);
      this.jejuAirport = new kakao.maps.LatLng(33.5113, 126.4928);
      this.mokpoPort = new kakao.maps.LatLng(34.7819, 126.3722);
      this.jejuPort = new kakao.maps.LatLng(33.5186, 126.5292);

      this.makeMap();
      this.initRoadview();

      $('#btn-my-location').click(() => {
        this.toggleCurrentLocation();
      });

      $('#btn-jeju').click(() => {
        this.toggleJejuLocation();
      });

      $('#btn-route').click(() => {
        this.showRouteAndAnimate('plane');
      });

      $('#btn-route-sea').click(() => {
        this.showRouteAndAnimate('sea');
      });

      $('#btn-jeju-main').click(function() {
        $(this).hide();
        $('#jeju-options-container').show();
      });

      $('#btn-jeju-back').click(function() {
        $('#jeju-options-container').hide();
        $('#btn-jeju-main').show();
      });
    },

    makeMap: function () {
      const mapContainer = document.getElementById('map1');
      const mapOption = { center: new kakao.maps.LatLng(37.538453, 127.053110), level: 5 };
      this.map = new kakao.maps.Map(mapContainer, mapOption);
      this.map.addControl(new kakao.maps.MapTypeControl(), kakao.maps.ControlPosition.TOPRIGHT);
      this.map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);

      this.initClusterer();
      this.getCurrentLocation(true);
    },

    initClusterer: function() {
      const positions = [
        {title: '독립기념관', lat: 36.781460, lng: 127.226502, img: 'nv1.jpg'},
        {title: '유관순 열사 유적지', lat: 36.759298, lng: 127.308414, img: 'nv2.jpg'},
        {title: '천안삼거리공원', lat: 36.784192, lng: 127.167536, img: 'nv3.jpg'},
        {title: '아라리오 조각광장', lat: 36.819381, lng: 127.157271, img: 'nv4.jpg'},
        {title: '광덕산', lat: 36.693010, lng: 127.025793, img: 'nv5.jpg'},
        {title: '한라산', lat: 33.362418, lng: 126.528952, img: 'nv6.jpg'},
        {title: '성산일출봉', lat: 33.458807, lng: 126.942457, img: 'nv7.jpg'},
        {title: '섭지코지', lat: 33.424315, lng: 126.931117, img: 'nv8.jpg'},
        {title: '만장굴', lat: 33.528389, lng: 126.770287, img: 'nv9.jpg'},
        {title: '함덕 해수욕장', lat: 33.544173, lng: 126.669603, img: 'nv10.jpg'}
      ];

      const imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png';
      const imageSize = new kakao.maps.Size(24, 35);

      positions.forEach((position, index) => {
        const markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize);
        const marker = new kakao.maps.Marker({
          position: new kakao.maps.LatLng(position.lat, position.lng),
          image: markerImage,
          title: position.title
        });

        marker.setMap(this.map);
        this.touristMarkers.push(marker);

        // 커스텀 오버레이 컨텐츠 - 크기 축소
        const content = '<div class="wrap" style="position:absolute;left:-55px;bottom:40px;width:220px;height:auto;margin-left:-110px;text-align:left;overflow:hidden;font-size:11px;font-family:\'Malgun Gothic\',dotum,\'돋움\',sans-serif;line-height:1.4;">' +
                '    <div style="border:1px solid #ccc;border-bottom:2px solid #ddd;background:#fff;box-shadow: 0 1px 2px #888;">' +
                '        <div style="height:28px;background:#007bff;padding:4px 8px;color:#fff;font-size:13px;font-weight:bold;display:flex;align-items:center;justify-content:space-between;">' +
                '            <span>' + position.title + '</span>' +
                '            <div class="close" onclick="map1.closeOverlay(' + index + ')" title="닫기" style="color:#fff;width:15px;height:15px;cursor:pointer;background:url(\'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/overlay_close.png\') no-repeat;background-size:contain;"></div>' +
                '        </div>' +
                '        <div style="padding:8px;">' +
                '            <div style="text-align:center;margin-bottom:8px;">' +
                '                <img src="/img/' + position.img + '" width="200" height="130" style="border-radius:4px;">' +
                '            </div>' +
                '            <div style="text-align:center;">' +
                '                <button onclick="map1.findRoute(' + position.lat + ',' + position.lng + ',\'' + position.title + '\')" style="padding:6px 16px;background:#007bff;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:12px;font-weight:bold;">길찾기</button>' +
                '            </div>' +
                '        </div>' +
                '    </div>' +
                '</div>';

        // 커스텀 오버레이 생성
        const customOverlay = new kakao.maps.CustomOverlay({
          content: content,
          position: marker.getPosition(),
          xAnchor: 0.5,
          yAnchor: 1,
          zIndex: 3
        });

        // 마커 클릭 이벤트
        kakao.maps.event.addListener(marker, 'click', () => {
          this.closeAllOverlays();
          customOverlay.setMap(this.map);
          this.activeOverlay = customOverlay;

          // 로그 기록 - 지역 정보와 장소명 전송
          this.logMarkerClick(position.title, position.lat, position.lng);
        });

        if (!this.touristOverlays) this.touristOverlays = [];
        this.touristOverlays.push(customOverlay);
      });
    },

    // 마커 클릭 로그 기록 함수 추가
    logMarkerClick: function(placeName, lat, lng) {
      // 좌표로 지역 정보 가져오기
      const geocoder = new kakao.maps.services.Geocoder();
      const position = new kakao.maps.LatLng(lat, lng);

      geocoder.coord2RegionCode(lng, lat, (result, status) => {
        let region = '알 수 없는 지역';

        if (status === kakao.maps.services.Status.OK && result.length > 0) {
          // 시/군/구 단위까지만 추출
          region = result[0].address_name || result[0].region_1depth_name + ' ' + result[0].region_2depth_name;
        }

        // 서버에 로그 전송
        $.ajax({
          url: '/maplog/click',
          type: 'POST',
          data: {
            name: placeName,
            region: region
          },
          success: function(response) {
            console.log('로그 기록 완료:', placeName, region);
          },
          error: function(error) {
            console.error('마커 클릭 로그 기록 실패:', error);
          }
        });
      });
    },

    toggleCurrentLocation: function() {
      if (this.currentLocationMarker.getMap()) {
        this.currentLocationMarker.setMap(null);
      } else {
        this.getCurrentLocation(true);
      }
    },

    getCurrentLocation: function(panTo = false) {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          this.currentPosition = new kakao.maps.LatLng(lat, lng);
          this.currentLocationMarker.setPosition(this.currentPosition);
          this.currentLocationMarker.setMap(this.map);

          if(panTo) {
            this.map.setLevel(8);
            this.map.panTo(this.currentPosition);
          }
          this.goMap(this.currentPosition);
        }, (error) => {
          console.error('위치 정보 오류:', error);
          this.currentPosition = new kakao.maps.LatLng(37.538453, 127.053110);
          this.currentLocationMarker.setPosition(this.currentPosition);
          this.currentLocationMarker.setMap(this.map);
          if(panTo) this.map.panTo(this.currentPosition);
        });
      } else {
        alert('Geolocation을 지원하지 않는 브라우저입니다.');
      }
    },

    toggleJejuLocation: function() {
      if (this.jejuMarker.getMap()) {
        this.jejuMarker.setMap(null);
      } else {
        this.map.setLevel(9);
        this.map.panTo(this.jejuPosition);
        this.jejuMarker.setPosition(this.jejuPosition);
        this.jejuMarker.setMap(this.map);
      }
    },

    showRouteAndAnimate: function(type) {
      if (!this.currentPosition) {
        alert('현재 위치가 설정되지 않았습니다. "나에게 이동" 버튼을 먼저 클릭해주세요.');
        return;
      }

      this.polylines.forEach(line => line.setMap(null));
      this.polylines = [];
      this.planeMarker.setMap(null);
      this.boatMarker.setMap(null);

      let path1, path2, path3;
      let startPoint, midPoint1, midPoint2, endPoint;
      let dist1, dist2, dist3, totalDistance;
      let time1, time2, time3, totalTime;
      let infoHTML;
      let bounds = new kakao.maps.LatLngBounds();

      if (type === 'plane') {
        startPoint = this.currentPosition;
        midPoint1 = this.gimpoAirport;
        midPoint2 = this.jejuAirport;
        endPoint = this.jejuPosition;

        this.currentLocationMarker.setMap(this.map);
        this.jejuMarker.setMap(this.map);
        this.airportMarker.setPosition(midPoint1);
        this.airportMarker.setMap(this.map);
        this.jejuAirportMarker.setPosition(midPoint2);
        this.jejuAirportMarker.setMap(this.map);
        this.portMarker.setMap(null);
        this.jejuPortMarker.setMap(null);

        path1 = [startPoint, midPoint1];
        path2 = [midPoint1, midPoint2];
        path3 = [midPoint2, endPoint];

        dist1 = this.getDistance(startPoint, midPoint1);
        dist2 = this.getDistance(midPoint1, midPoint2);
        dist3 = this.getDistance(midPoint2, endPoint);
        totalDistance = dist1 + dist2 + dist3;
        time1 = Math.round(dist1 / 600);
        time2 = Math.round(dist2 / 800000 * 60);
        time3 = Math.round(dist3 / 600);
        totalTime = time1 + time2 + time3 + 60;

        infoHTML = '<h4>제주도 비행기 경로</h4>' +
                '<div class="route-step active" id="step1"><div class="step-title">1. 현재 위치 → 김포공항</div><div class="step-info"> 이동수단: 버스/지하철</div><div class="step-info"> 거리: ' + (dist1/1000).toFixed(1) + 'km</div><div class="step-info"> 소요시간: 약 ' + time1 + '분</div></div>' +
                '<div class="route-step" id="step2"><div class="step-title">2. 김포공항 → 제주공항</div><div class="step-info"> 이동수단: 비행기</div><div class="step-info"> 거리: ' + (dist2/1000).toFixed(1) + 'km</div><div class="step-info"> 비행시간: 약 ' + time2 + '분</div></div>' +
                '<div class="route-step" id="step3"><div class="step-title">3. 제주공항 → 목적지</div><div class="step-info"> 이동수단: 택시/렌터카</div><div class="step-info"> 거리: ' + (dist3/1000).toFixed(1) + 'km</div><div class="step-info"> 소요시간: 약 ' + time3 + '분</div></div>' +
                '<div class="total-info">총 거리: ' + (totalDistance/1000).toFixed(1) + 'km<br>총 소요시간: 약 ' + Math.floor(totalTime/60) + '시간 ' + (totalTime%60) + '분</div>';

      } else if (type === 'sea') {
        startPoint = this.currentPosition;
        midPoint1 = this.mokpoPort;
        midPoint2 = this.jejuPort;
        endPoint = this.jejuPosition;

        this.currentLocationMarker.setMap(this.map);
        this.jejuMarker.setMap(this.map);
        this.portMarker.setPosition(midPoint1);
        this.portMarker.setMap(this.map);
        this.jejuPortMarker.setPosition(midPoint2);
        this.jejuPortMarker.setMap(this.map);
        this.airportMarker.setMap(null);
        this.jejuAirportMarker.setMap(null);

        path1 = [startPoint, midPoint1];
        path2 = [midPoint1, midPoint2];
        path3 = [midPoint2, endPoint];

        dist1 = this.getDistance(startPoint, midPoint1);
        dist2 = this.getDistance(midPoint1, midPoint2);
        dist3 = this.getDistance(midPoint2, endPoint);
        totalDistance = dist1 + dist2 + dist3;
        time1 = Math.round(dist1 / 1200);
        time2 = Math.round(dist2 / 40000 * 60);
        time3 = Math.round(dist3 / 600);
        totalTime = time1 + time2 + time3 + 60;

        infoHTML = '<h4>제주도 배편 경로</h4>' +
                '<div class="route-step active" id="step1"><div class="step-title">1. 현재 위치 → 목포항</div><div class="step-info"> 이동수단: 자동차</div><div class="step-info"> 거리: ' + (dist1/1000).toFixed(1) + 'km</div><div class="step-info"> 소요시간: 약 ' + Math.floor(time1/60) + '시간 ' + (time1%60) + '분</div></div>' +
                '<div class="route-step" id="step2"><div class="step-title">2. 목포항 → 제주항</div><div class="step-info"> 이동수단: 여객선</div><div class="step-info"> 거리: ' + (dist2/1000).toFixed(1) + 'km</div><div class="step-info"> 항해시간: 약 ' + Math.floor(time2/60) + '시간 ' + (time2%60) + '분</div></div>' +
                '<div class="route-step" id="step3"><div class="step-title">3. 제주항 → 목적지</div><div class="step-info"> 이동수단: 택시/렌터카</div><div class="step-info"> 거리: ' + (dist3/1000).toFixed(1) + 'km</div><div class="step-info"> 소요시간: 약 ' + time3 + '분</div></div>' +
                '<div class="total-info">총 거리: ' + (totalDistance/1000).toFixed(1) + 'km<br>총 소요시간: 약 ' + Math.floor(totalTime/60) + '시간 ' + (totalTime%60) + '분</div>';
      }

      const polyline1 = new kakao.maps.Polyline({ path: path1, strokeWeight: 7, strokeColor: '#4A90E2', strokeOpacity: 0.8, strokeStyle: 'solid' });
      const polyline2 = new kakao.maps.Polyline({ path: path2, strokeWeight: 7, strokeColor: (type === 'plane' ? '#FF6B6B' : '#3a86ff'), strokeOpacity: 0.8, strokeStyle: 'dashed' });
      const polyline3 = new kakao.maps.Polyline({ path: path3, strokeWeight: 7, strokeColor: '#4CAF50', strokeOpacity: 0.8, strokeStyle: 'solid' });

      polyline1.setMap(this.map);
      polyline2.setMap(this.map);
      polyline3.setMap(this.map);
      this.polylines.push(polyline1, polyline2, polyline3);

      const routeInfo = document.getElementById('routeInfo');
      routeInfo.innerHTML = infoHTML;
      routeInfo.className = 'active';

      bounds.extend(startPoint);
      bounds.extend(midPoint1);
      bounds.extend(midPoint2);
      bounds.extend(endPoint);
      this.map.setBounds(bounds);

      setTimeout(() => {
        this.animateRoute(type, startPoint, midPoint1, midPoint2, endPoint);
      }, 1500);
    },

    animateRoute: function(type, startPoint, midPoint1, midPoint2, endPoint) {
      const marker = (type === 'plane') ? this.planeMarker : this.boatMarker;
      const durations = (type === 'plane') ? [5000, 8000, 3000] : [7000, 10000, 3000];

      this.animateStep(marker, startPoint, midPoint1, durations[0], 'step1', () => {
        this.animateStep(marker, midPoint1, midPoint2, durations[1], 'step2', () => {
          this.animateStep(marker, midPoint2, endPoint, durations[2], 'step3', () => {
            setTimeout(() => {
              marker.setMap(null);
              this.polylines.forEach(line => line.setMap(null));
              this.polylines = [];
              document.getElementById('routeInfo').className = '';
              alert('제주도에 도착했습니다! 즐거운 여행 되세요!');
            }, 1000);
          });
        });
      });
    },

    animateStep: function(marker, startPos, endPos, duration, stepId, callback) {
      const startLat = startPos.getLat();
      const startLng = startPos.getLng();
      const endLat = endPos.getLat();
      const endLng = endPos.getLng();

      const frames = 100;
      const interval = duration / frames;
      let currentFrame = 0;

      document.querySelectorAll('.route-step').forEach(step => step.classList.remove('active'));
      document.getElementById(stepId).classList.add('active');

      marker.setMap(this.map);

      const animate = () => {
        if (currentFrame <= frames) {
          const progress = currentFrame / frames;
          const easeProgress = progress < 0.5 ? 2 * progress * progress : 1 - Math.pow(-2 * progress + 2, 2) / 2;

          const lat = startLat + (endLat - startLat) * easeProgress;
          const lng = startLng + (endLng - startLng) * easeProgress;

          marker.setPosition(new kakao.maps.LatLng(lat, lng));
          currentFrame++;
          setTimeout(animate, interval);
        } else {
          if (callback) callback();
        }
      };
      animate();
    },

    getDistance: function(pos1, pos2) {
      const R = 6371000;
      const lat1 = pos1.getLat() * Math.PI / 180;
      const lat2 = pos2.getLat() * Math.PI / 180;
      const deltaLat = (pos2.getLat() - pos1.getLat()) * Math.PI / 180;
      const deltaLng = (pos2.getLng() - pos1.getLng()) * Math.PI / 180;

      const a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
              Math.cos(lat1) * Math.cos(lat2) *
              Math.sin(deltaLng/2) * Math.sin(deltaLng/2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      return R * c;
    },

    initRoadview: function() {
      const rvContainer = document.getElementById('roadview');
      this.rv = new kakao.maps.Roadview(rvContainer);
      this.rvClient = new kakao.maps.RoadviewClient();

      kakao.maps.event.addListener(this.rv, 'position_changed', () => {
        const rvPosition = this.rv.getPosition();
        this.map.setCenter(rvPosition);
        if(this.overlayOn) this.roadviewMarker.setPosition(rvPosition);
      });

      const roadviewMarkerImage = new kakao.maps.MarkerImage(
              'https://t1.daumcdn.net/localimg/localimages/07/2018/pc/roadview_minimap_wk_2018.png',
              new kakao.maps.Size(26, 46), {
                spriteSize: new kakao.maps.Size(1666, 168),
                spriteOrigin: new kakao.maps.Point(705, 114),
                offset: new kakao.maps.Point(13, 46)
              }
      );
      this.roadviewMarker = new kakao.maps.Marker({
        image: roadviewMarkerImage,
        position: this.map.getCenter(),
        draggable: true
      });

      kakao.maps.event.addListener(this.roadviewMarker, 'click', () => {
        this.roadviewMarker.setMap(null);
      });

      kakao.maps.event.addListener(this.roadviewMarker, 'dragend', () => {
        if (this.overlayOn) this.toggleRoadview(this.roadviewMarker.getPosition());
      });

      kakao.maps.event.addListener(this.map, 'click', (mouseEvent) => {
        const position = mouseEvent.latLng;
        this.roadviewMarker.setPosition(position);
        this.roadviewMarker.setMap(this.map);
        if(this.overlayOn) this.toggleRoadview(position);
      });
    },

    toggleRoadview: function (position){
      this.rvClient.getNearestPanoId(position, 50, (panoId) => {
        if (panoId === null) {
          this.toggleMapWrapper(true, position);
          alert('해당 위치에는 로드뷰 정보가 없습니다.');
        } else {
          this.toggleMapWrapper(false, position);
          this.rv.setPanoId(panoId, position);
        }
      });
    },

    toggleMapWrapper: function (active, position) {
      this.container.className = active ? '' : 'view_roadview';
      this.map.relayout();
      this.map.setCenter(position);
    },

    toggleOverlay: function (active) {
      if (active) {
        if (this.roadviewMarker.getMap() === null) {
          alert('먼저 지도 위를 클릭하여 로드뷰 위치를 지정해주세요.');
          this.setRoadviewRoad(true);
          return;
        }
        this.overlayOn = true;
        this.map.addOverlayMapTypeId(kakao.maps.MapTypeId.ROADVIEW);
        this.toggleRoadview(this.roadviewMarker.getPosition());
      } else {
        this.overlayOn = false;
        this.map.removeOverlayMapTypeId(kakao.maps.MapTypeId.ROADVIEW);
      }
    },

    setRoadviewRoad: function (forceOff = false) {
      const control = document.getElementById('roadviewControl');
      if (forceOff || control.className.indexOf('active') !== -1) {
        control.className = '';
        this.toggleOverlay(false);
      } else {
        control.className = 'active';
        this.toggleOverlay(true);
      }
    },

    closeRoadview: function () {
      this.toggleMapWrapper(true, this.roadviewMarker.getPosition());
    },

    goMap: function (locPosition) {
      const geocoder = new kakao.maps.services.Geocoder();
      geocoder.coord2RegionCode(locPosition.getLng(), locPosition.getLat(), this.addDisplay1.bind(this));
      geocoder.coord2Address(locPosition.getLng(), locPosition.getLat(), this.addDisplay2.bind(this));
    },

    closeAllOverlays: function() {
      if (this.touristOverlays) {
        this.touristOverlays.forEach(overlay => {
          overlay.setMap(null);
        });
      }
      this.activeOverlay = null;
    },

    closeOverlay: function(index) {
      if (this.touristOverlays && this.touristOverlays[index]) {
        this.touristOverlays[index].setMap(null);
      }
      // 오버레이 닫을 때 경로선도 제거
      this.polylines.forEach(line => line.setMap(null));
      this.polylines = [];
    },

    // Valhalla
    findRoute: function(lat, lng, title) {
      if (!this.currentPosition) {
        alert('현재 위치가 설정되지 않았습니다. "나에게 이동" 버튼을 먼저 클릭해주세요.');
        return;
      }

      const destination = new kakao.maps.LatLng(lat, lng);
      const startLng = this.currentPosition.getLng();
      const startLat = this.currentPosition.getLat();

      // 기존 경로선 제거
      this.polylines.forEach(line => line.setMap(null));
      this.polylines = [];

      // 방법 1: Valhalla API 시도 (Mapbox 무료)
      const valhallaUrl = 'https://valhalla1.openstreetmap.de/route';
      const valhallaData = {
        locations: [
          {lat: startLat, lon: startLng},
          {lat: lat, lon: lng}
        ],
        costing: 'auto',
        directions_options: {language: 'ko-KR'}
      };

      fetch(valhallaUrl, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(valhallaData)
      })
              .then(response => response.json())
              .then(data => {
                if (data.trip && data.trip.legs && data.trip.legs.length > 0) {
                  const leg = data.trip.legs[0];
                  const shape = leg.shape;

                  // Polyline 디코딩
                  const path = this.decodePolyline(shape);

                  // 경로선 그리기
                  const polyline = new kakao.maps.Polyline({
                    path: path,
                    strokeWeight: 5,
                    strokeColor: '#FF0000',
                    strokeOpacity: 0.7,
                    strokeStyle: 'solid'
                  });

                  polyline.setMap(this.map);
                  this.polylines.push(polyline);

                  // 지도 범위 조정
                  const bounds = new kakao.maps.LatLngBounds();
                  path.forEach(p => bounds.extend(p));
                  this.map.setBounds(bounds);

                  // 거리 및 시간 정보
                  const distance = leg.summary.length * 1000; // km → m
                  const duration = leg.summary.time; // 초
                  const distanceKm = (distance / 1000).toFixed(1);
                  const durationMin = Math.round(duration / 60);

                  alert(title + '까지\n거리: ' + distanceKm + 'km\n예상 소요시간: 약 ' + durationMin + '분');
                } else {
                  console.log('Valhalla API 실패, 직선 경로로 표시');
                  this.drawStraightRoute(destination, title);
                }
              })
              .catch(error => {
                console.log('Valhalla API 오류, 직선 경로로 표시:', error);
                this.drawStraightRoute(destination, title);
              });
    },

    // Polyline 디코딩 함수 (Valhalla 형식)
    decodePolyline: function(encoded, precision = 6) {
      const factor = Math.pow(10, precision);
      let index = 0;
      let lat = 0;
      let lng = 0;
      const coordinates = [];

      while (index < encoded.length) {
        let b, shift = 0, result = 0;
        do {
          b = encoded.charCodeAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        const deltaLat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += deltaLat;

        shift = 0;
        result = 0;
        do {
          b = encoded.charCodeAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        const deltaLng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += deltaLng;

        coordinates.push(new kakao.maps.LatLng(lat / factor, lng / factor));
      }
      return coordinates;
    },

    drawStraightRoute: function(destination, title) {
      const distance = this.getDistance(this.currentPosition, destination);

      const path = [this.currentPosition, destination];
      const polyline = new kakao.maps.Polyline({
        path: path,
        strokeWeight: 5,
        strokeColor: '#FF0000',
        strokeOpacity: 0.7,
        strokeStyle: 'solid'
      });

      polyline.setMap(this.map);
      this.polylines.push(polyline);

      const bounds = new kakao.maps.LatLngBounds();
      bounds.extend(this.currentPosition);
      bounds.extend(destination);
      this.map.setBounds(bounds);

      const distanceKm = (distance / 1000).toFixed(1);
      const estimatedTime = Math.round(distance / 1000);
      alert(title + '까지\n직선거리: ' + distanceKm + 'km\n예상 소요시간: 약 ' + estimatedTime + '분\n(도로 경로는 API 키 설정 후 사용 가능)');
    }
  }

  $(function () { map1.init() });
</script>

<div class="col-sm-10">
  <h5 id="latlng"></h5>
  <h3 id="addr1"></h3>
  <h3 id="addr2"></h3>

  <button id="btn-my-location" class="btn btn-info">나에게 이동</button>

  <button id="btn-jeju-main" class="btn btn-success">제주도 가기</button>

  <div id="jeju-options-container" style="display:none;">
    <div class="btn-group" role="group">
      <button id="btn-jeju" class="btn btn-outline-success">위치 이동</button>
      <button id="btn-route" class="btn btn-outline-warning">비행기 경로</button>
      <button id="btn-route-sea" class="btn btn-outline-primary">배편 경로</button>
      <button id="btn-jeju-back" class="btn btn-secondary">뒤로</button>
    </div>
  </div>

  <div id="container">
    <div id="routeInfo"></div>
    <div id="rvWrapper">
      <div id="roadview" style="width:100%;height:100%;"></div>
      <div id="close" title="로드뷰닫기" onclick="map1.closeRoadview()"><span class="img"></span></div>
    </div>
    <div id="mapWrapper">
      <div id="map1" style="width:100%;height:100%"></div>
      <div id="roadviewControl" onclick="map1.setRoadviewRoad()"></div>
    </div>
  </div>
</div>
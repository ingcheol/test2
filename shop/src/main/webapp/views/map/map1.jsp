<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  /* Map 페이지 전용 스타일 */
  .map-container {
    padding: 40px 20px;
    background: #f5f5f5;
    min-height: 100vh;
  }

  .map-header {
    text-align: center;
    color: white;
    margin-bottom: 30px;
    animation: fadeInDown 0.8s ease;
  }

  .map-header h2 {
    font-size: 2.5rem;
    font-weight: bold;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    margin-bottom: 15px;
  }

  .location-info {
    background: white;
    padding: 25px;
    border-radius: 15px;
    margin-bottom: 20px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    animation: fadeInUp 0.8s ease 0.2s both;
  }

  .location-info h5 {
    color: #667eea;
    font-weight: 600;
    margin-bottom: 10px;
    font-size: 0.9rem;
  }

  .location-info h3 {
    color: #333;
    font-size: 1.1rem;
    margin: 8px 0;
    font-weight: 500;
  }

  .map-controls {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
    justify-content: center;
    animation: fadeInUp 0.8s ease 0.4s both;
  }

  .map-btn {
    padding: 12px 30px;
    border-radius: 25px;
    border: none;
    font-weight: 600;
    font-size: 15px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
  }

  .map-btn.hospital {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }

  .map-btn.hospital:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
  }

  .map-btn.store {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
  }

  .map-btn.store:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(245, 87, 108, 0.4);
  }

  #map1 {
    width: 100%;
    height: 500px;
    border-radius: 15px;
    overflow: hidden;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    animation: fadeInUp 0.8s ease 0.6s both;
  }

  @keyframes fadeInDown {
    from {
      opacity: 0;
      transform: translateY(-20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  /* 반응형 */
  @media (max-width: 768px) {
    .map-header h2 {
      font-size: 2rem;
    }

    .map-controls {
      flex-direction: column;
    }

    #map1 {
      height: 400px;
    }
  }
</style>
<script>
  let map1 = {
    addr:null,
    map:null,
    init:function(){
      this.makeMap();
      $('#btn1').click(()=>{
        this.getData(10);
      });
      $('#btn2').click(()=>{
        this.addr ? this.getData(20) : alert('주소를 찾을수 없어요');
      });
    },

    makeMap: function(){
      let mapContainer = document.getElementById('map1');
      let mapOption = {
        center: new kakao.maps.LatLng(37.538453, 127.053110),
        level: 5
      }
      this.map = new kakao.maps.Map(mapContainer, mapOption);
      let mapTypeControl = new kakao.maps.MapTypeControl();
      this.map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
      let zoomControl = new kakao.maps.ZoomControl();
      this.map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

      if (navigator.geolocation) {
        // GeoLocation을 이용해서 접속 위치를 얻어옵니다
        navigator.geolocation.getCurrentPosition((position)=>{
          let lat = position.coords.latitude;  // 위도
          let lng = position.coords.longitude; // 경도
          $('#latlng').html(lat+' '+lng);
          let locPosition = new kakao.maps.LatLng(lat, lng);
          this.goMap(locPosition);
        });

      }else{
        alert('지원하지 않습니다.');
      } // end if
    },
    goMap: function(locPosition){
      // 마커를 생성합니다
      let marker = new kakao.maps.Marker({
        map: this.map,
        position: locPosition
      });
      this.map.panTo(locPosition);

      let geocoder = new kakao.maps.services.Geocoder();
      // 간단 주소 호출
      geocoder.coord2RegionCode(locPosition.getLng(), locPosition.getLat(), this.addDisplay1.bind(this));
      // 상세 주소 호출
      geocoder.coord2Address(locPosition.getLng(), locPosition.getLat(), this.addDisplay2.bind(this));

    },
    addDisplay1:function(result, status){
      if (status === kakao.maps.services.Status.OK) {
        $('#addr1').html(result[0].address_name);
        this.addr = result[0].address_name;
      }
    },
    addDisplay2:function(result, status){
      if (status === kakao.maps.services.Status.OK) {
        var detailAddr = result[0].road_address ? '<div>도로명주소 : ' + result[0].road_address.address_name + '</div>' : '';
        detailAddr += '<div>지번 주소 : ' + result[0].address.address_name + '</div>';
        $('#addr2').html(detailAddr);
      }
    },
    getData:function(type){

      $.ajax({
        url:'/getaddrshop',
        data:{addr:this.addr, type:type},
        success:(result)=>{alert(result)}
      });
    }
  }
  $(function(){
    map1.init()
  })
</script>


<div class="col-sm-10">
  <h2>Map1</h2>
  <h5 id="latlng"></h5>
  <h3 id="addr1"></h3>
  <h3 id="addr2"></h3>
  <button id="btn1" class="btn btn-primary">병원</button>
  <button id="btn2" class="btn btn-primary">편의점</button>
  <div id="map1"></div>
</div>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #map1{
    width:auto;
    height:400px;
    border:2px solid red;
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

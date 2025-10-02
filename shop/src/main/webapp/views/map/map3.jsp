<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--Center Page--%>
<style>
  #map{
    width: auto;
    height: 300px;
    border: 2px solid red;
  }
  #content{
    margin-top: 120px;
    width:auto;
    height:300px;
    border: 2px solid red;
    overflow: auto;
  }
</style>
<script>
  const map3 = {
    map:null,
    target: 100,
    type: 10,
    markers:[],
    showMarkers:function(map){
      $(this.markers).each((index,item)=>{
        item.setMap(map);
      });
    },
    init:function(){
      this.makeMap(37.554472, 126.980841);

      $('#sbtn').click(()=>{
        this.target = 100;
        this.makeMap(37.554472, 126.980841);
      });
      $('#bbtn').click(()=>{
        this.target = 200;
        this.makeMap(35.175109, 129.175474);
      });
      $('#jbtn').click(()=>{
        this.target = 300;
        this.makeMap(33.254564, 126.560944);
      });
      $('#bank_btn').click(()=>{
        this.showMarkers(null); // 마커 지우기
        this.markers = []; // 배열에 마커들 모두 지우기
        this.type = 10;
        this.getData()
      });
      $('#shop_btn').click(()=>{
        this.showMarkers(null);
        this.markers = [];
        this.type = 20;
        this.getData()
      });
      $('#hos_btn').click(()=>{
        this.showMarkers(null);
        this.markers = [];
        this.type = 30;
        this.getData()
      });
    },
    makeMap:function(lat, lng){
      var mapContainer = document.getElementById('map');
      var mapOption = {
        center: new kakao.maps.LatLng(lat, lng),
        level: 7
      };
      this.map = new kakao.maps.Map(mapContainer, mapOption);

      var mapTypeControl = new kakao.maps.MapTypeControl();
      this.map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
      var zoomControl = new kakao.maps.ZoomControl();
      this.map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);
    },
    getData:function(){
      $.ajax({
        url:'<c:url value="/getcontents"/>',
        data:{target:this.target,type:this.type },
        // [{{},{}]
        success:(result)=>{
          this.makeMarkers(result);
        },
        error:()=>{}
      });
    },

    makeMarkers:function(datas){

      // 배열을 돌려서 (each)
      // 각 데이터를 이용하여 마커를 생성 하고
      // 각 마커에 인포윈도우를 생성 하고
      // 각 마커에 이벤트를 등록 한다.
      let imgSrc1 = 'https://t1.daumcdn.net/localimg/localimages/07/2012/img/marker_p.png';
      let imgSrc2 = '<c:url value="/img/m.jpg"/> ';


      let result = '';

      $(datas).each((index,item)=>{
        let imgSize = new kakao.maps.Size(30,30);
        let markerImg = new kakao.maps.MarkerImage(imgSrc1, imgSize);

        var markerPosition  = new kakao.maps.LatLng(item.lat, item.lng);
        var marker = new kakao.maps.Marker({
          image: markerImg,
          position: markerPosition
        });

        let iwContent = '<p>'+item.title+'</p>';
        iwContent += '<img style="width:80px;" src="<c:url value="/img/'+item.img+'"/> ">';

        var infowindow = new kakao.maps.InfoWindow({
          content : iwContent,

        });
        kakao.maps.event.addListener(marker, 'mouseover', function() {
          infowindow.open(this.map, marker);
        });
        kakao.maps.event.addListener(marker, 'mouseout', function() {
          infowindow.close();
        });
        kakao.maps.event.addListener(marker, 'click', function() {
          // 127.0.0.1/map/go
          location.href = '<c:url value="/map/go?target='+item.target+'"/>';
        });
        this.markers.push(marker);
        // Make Content List
        result += '<p>';
        result += '<a href="<c:url value="/map/go?target='+item.target+'"/>">';
        result += '<img width="20px" src="<c:url value="/img/'+item.img+'"/> ">';
        result += item.target+' '+item.title;
        result += '</a>';
        result += '</p>';
      });

      $('#content').html(result);
      this.showMarkers(this.map);


    }

  }
  $(function(){
    map3.init();
  });
</script>

<div class="col-sm-10">
  <div class="row">
    <div class="col-sm-8 col-lg-6">
      <h2>Map3 Page</h2>
      <button id="sbtn" class="btn btn-primary">서울</button>
      <button id="bbtn" class="btn btn-primary">부산</button>
      <button id="jbtn" class="btn btn-primary">제주</button>
      <br>
      <button id="bank_btn" class="btn btn-danger">은행</button>
      <button id="shop_btn" class="btn btn-danger">식당</button>
      <button id="hos_btn" class="btn btn-danger">병원</button>
      <div id="map"></div>
    </div>
    <div class="col-sm-4 col-lg-6">
      <div id="content"></div>
    </div>
  </div>
</div>
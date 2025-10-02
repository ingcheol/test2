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
    map:null,
    marker:null,

    init:function(){
      this.makeMap();
      setInterval(()=>{this.getData()}, 3000);
    },
    getData:function(){
      $.ajax({
        url:'/getlatlng',
        success:(result)=>{
          this.showMarker(result);
        }
      });
    },
    showMarker:function(result){
      if(this.marker != null){
        this.marker.setMap(null);
      }

      let imgSrc = '<c:url value="/img/auto.jpg"/> ';
      let imgSize = new kakao.maps.Size(30,30);
      let markerImg = new kakao.maps.MarkerImage(imgSrc, imgSize);

      let position = new kakao.maps.LatLng(result.lat, result.lng);
      this.marker = new kakao.maps.Marker({
        image: markerImg,
        position:position
      });
      this.marker.setMap(this.map);
    },
    makeMap:function(){
      let mapContainer = document.getElementById('map1');
      let mapOption = {
        center: new kakao.maps.LatLng(36.800209, 127.074968),
        level: 5
      }
      this.map = new kakao.maps.Map(mapContainer, mapOption);
      let mapTypeControl = new kakao.maps.MapTypeControl();
      this.map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
      let zoomControl = new kakao.maps.ZoomControl();
      this.map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

      // Marker 생성
      let markerPosition  = new kakao.maps.LatLng(36.800209, 127.074968);
      let marker = new kakao.maps.Marker({
        position: markerPosition,
        map:this.map
      });
    }
  }
  $(function(){
    map1.init()
  })
</script>


<div class="col-sm-10">
  <h2>Map4</h2>
  <div id="map1"></div>
</div>

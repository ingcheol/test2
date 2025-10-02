<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
  #map{
    width: auto;
    height: 300px;
    border: 2px solid red;
  }
</style>

<script>
  const go = {
    init:function(){
      this.makeMap();
    },
    makeMap:function(){
      let lat = ${marker.lat};
      let lng = ${marker.lng};

      var mapContainer = document.getElementById('map');
      var mapOption = {
        center: new kakao.maps.LatLng(lat, lng),
        level: 5
      };
      var map = new kakao.maps.Map(mapContainer, mapOption);

      var mapTypeControl = new kakao.maps.MapTypeControl();
      map.addControl(mapTypeControl, kakao.maps.ControlPosition.TOPRIGHT);
      var zoomControl = new kakao.maps.ZoomControl();
      map.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

      var markerPosition  = new kakao.maps.LatLng(lat, lng);
      var marker = new kakao.maps.Marker({
        map:map,
        position: markerPosition
      });

    }
  }
  $(function(){
    go.init();
  });
</script>
<div class="col-sm-10">
  <h2>Go Page</h2>
  <h5>Shop Detail Page</h5>
  <h5>${marker.target}</h5>
  <h5>${marker.title}</h5>
  <h5>${marker.lat}</h5>
  <h5>${marker.lng}</h5>
  <h5>${marker.loc}</h5>
  <h5><img src="/img/${marker.img}"/></h5>
  <div id="map"></div>

</div>

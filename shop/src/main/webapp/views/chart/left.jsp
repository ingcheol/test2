<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <p>Chart Left Menu</p>
  <ul class="nav nav-pills flex-column">
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chart/chart1"/> ">chart1</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chart/chart2"/>">chart2</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chart/chart3"/>">chart3</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chart/chart4"/>">chart4</a>
    </li>
  </ul>
  <hr class="d-sm-none">
</div>
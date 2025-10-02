<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="col-sm-2">
  <p>Chat Left Menu</p>
  <ul class="nav nav-pills flex-column">
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chat/chat1"/> ">chat1</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chat/chat2"/>">chat2</a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<c:url value="/chat/chat3"/>">chat3</a>
    </li>
  </ul>
  <hr class="d-sm-none">
</div>
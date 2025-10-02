<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<style>
  #product_table > tbody > tr > td > img{
    width: 50px;
  }
</style>
<%-- Center Page --%>
<div class="col-sm-9">
  <h2>Product Get Page</h2>

  <form action="/product/search" method="get"
        style="margin-bottom: 30px;" id="search_form" class="form-inline well">
    <div class="form-group">
      <label for="name">Name:</label>
      <input type="text" name="productName" class="form-control" id="name"
        <c:if test="${productName != null}">
             value="${productName}"
        </c:if>
      >
    </div>
    <div class="form-group">
      <label for="sprice">Start:</label>
      <input type="number" name="startPrice" class="form-control" id="sprice" min="0" step="5000"
          <c:choose>
              <c:when test="${startPrice != null}">
                    value="${startPrice}"
              </c:when>
              <c:otherwise>
                    value="0"
              </c:otherwise>
          </c:choose>
      >
    </div>
    <div class="form-group">
      <label for="eprice">End:</label>
      <input type="number" name="endPrice" class="form-control" id="eprice" min="0" step="5000"
          <c:choose>
          <c:when test="${endPrice != null}">
                 value="${endPrice}"
          </c:when>
          <c:otherwise>
                 value="0"
          </c:otherwise>
          </c:choose>
      >
    </div>
    <div class="form-group">
      <label for="cate">Category:</label>
      <select class="form-control" name="cateId" id="cate">
        <option value="0" <c:if test="${cateId == 0}">selected</c:if>  >전체</option>
        <option value="10" <c:if test="${cateId == 10}">selected</c:if>>하의</option>
        <option value="20" <c:if test="${cateId == 20}">selected</c:if>>상의</option>
        <option value="30" <c:if test="${cateId == 30}">selected</c:if>>신발</option>
      </select>

    </div>
    <div class="form-group">
      <input type="submit" class="btn btn-info">Search</input>
    </div>
  </form>


  <table id="product_table" class="table table-bordered">
    <thead>
    <tr>
      <th>Img</th>
      <th>Id</th>
      <th>Name</th>
      <th>Price</th>
      <th>Rate</th>
      <th>RegDate</th>
      <th>Category</th>
    </tr>
    </thead>
    <tbody>
    <c:choose>
      <c:when test="${plist == null}">
        <h5>데이터가 없습니다.</h5>
      </c:when>
      <c:otherwise>
        <c:forEach var="p" items="${plist}">
          <tr>
            <td><img src="/imgs/${p.productImg}"></td>
            <td><a href="<c:url value="/product/detail?id=${p.productId}"/> ">${p.productId}</a></td>

            <td>${p.productName}</td>
            <td><fmt:formatNumber type="number" pattern="###,###원" value="${p.productPrice}" /></td>
            <td>${p.discountRate}</td>
            <td>
              <fmt:parseDate value="${ p.productRegdate }"
                             pattern="yyyy-MM-dd HH:mm:ss" var="parsedDateTime" type="both" />
              <fmt:formatDate pattern="yyyy년MM월dd일" value="${ parsedDateTime }" />
            </td>
            <td>${p.cateName}</td>
          </tr>
        </c:forEach>
      </c:otherwise>
    </c:choose>


    </tbody>
  </table>

</div>
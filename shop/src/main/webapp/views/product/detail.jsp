<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<script>
  let product_detail = {
    init:function(){
      $('#update_btn').click(()=>{
        let c = confirm('수정 하시겠습니까 ?');
        if(c == true){
          $('#product_update_form').attr('enctype', 'multipart/form-data');
          $('#product_update_form').attr('method', 'post');
          $('#product_update_form').attr('action','<c:url value="/product/updateimpl"/> ');
          $('#product_update_form').submit();
        }
      });
      $('#delete_btn').click(()=>{
        let c = confirm('삭제 하시겠습니까 ?');
        if(c == true){
          location.href='/product/delete?id=${p.productId}';
        }
      });
    }
  }
  $().ready(()=>{
    product_detail.init();
  });
</script>
<%-- Center Page --%>
<div class="col-sm-9">
  <h2>Product Detail Page</h2>
  <form id="product_update_form">
    <img src="/imgs/${p.productImg}">
    <div class="form-group">
      <label for="id">Id:</label>
      <p id="id">${p.productId}</p>
      <input type="hidden" name="productId" value="${p.productId}">
      <input type="hidden" name="productImg" value="${p.productImg}">
    </div>
    <div class="form-group">
      <label for="name">Name:</label>
      <input type="text" class="form-control" value="${p.productName}"  id="name" name="productName">
    </div>
    <div class="form-group">
      <label for="price">Price:</label>
      <input type="number" class="form-control" value="${p.productPrice}" id="price" name="productPrice">
    </div>
    <div class="form-group">
      <label for="rate">Discount Rate:</label>
      <input type="text" class="form-control" value="${p.discountRate}" id="rate" name="discountRate">
    </div>
    <div class="form-group">
      <label for="pimg">Product Image:</label>
      <input type="file" class="form-control" id="pimg" name="productImgFile">
    </div>
    <div class="form-group">
      <label for="cate">Cate Id:</label>
      <input type="number" class="form-control"  value="${p.cateId}" id="cate" name="cateId">
    </div>
    <div class="form-group">
      <label for="rdate">Register Date:</label>
      <p id="rdate">
        <fmt:parseDate value="${ p.productRegdate }"
                       pattern="yyyy-MM-dd HH:mm:ss" var="parsedDateTime" type="both" />
        <fmt:formatDate pattern="yyyy년MM월dd일 HH시mm분ss시" value="${ parsedDateTime }" /></p>
    </div>
    <div class="form-group">
      <label for="udate">Update Date:</label>
      <p id="udate">
        <fmt:parseDate value="${ p.productUpdate }"
                       pattern="yyyy-MM-dd HH:mm:ss" var="parsedDateTime" type="both" />
        <fmt:formatDate pattern="yyyy년MM월dd일 HH시mm분ss시" value="${ parsedDateTime }" />
      </p>
    </div>
    <button type="button" class="btn btn-primary" id="update_btn">Update</button>
    <button type="button" class="btn btn-primary" id="delete_btn">Delete</button>
  </form>

</div>
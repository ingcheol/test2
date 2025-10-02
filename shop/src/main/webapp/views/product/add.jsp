<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Center Page --%>
<div class="col-sm-9">
  <h2>Product Add Page</h2>
  <form action="/product/registerimpl" method="post" enctype="multipart/form-data">
    <div class="form-group">
      <label for="name">Name:</label>
      <input type="text" class="form-control" placeholder="Enter name" id="name" name="productName">
    </div>
    <div class="form-group">
      <label for="price">Price:</label>
      <input type="number" class="form-control" placeholder="Enter price" id="price" name="productPrice">
    </div>
    <div class="form-group">
      <label for="rate">Discount Rate:</label>
      <input type="number" min="0" step="0.1" class="form-control" placeholder="Enter discount rate" id="rate" name="discountRate">
    </div>
    <div class="form-group">
      <label for="pimg">Product Image:</label>
      <input type="file" class="form-control" placeholder="Select image" id="pimg" name="productImgFile">
    </div>
    <div class="form-group">
      <label for="cate">Cate Id:</label>
      <input type="number" class="form-control" placeholder="Enter cate id" id="cate" name="cateId">
    </div>
    <button type="submit" class="btn btn-primary">Register</button>
  </form>

</div>
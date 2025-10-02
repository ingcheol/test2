
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    $(function(){

    });
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Product Add</h1>
    </div>

    <!-- Content Row -->

    <div class="row">

        <div class="col-xl-10 col-lg-7">
            <div class="card shadow mb-4">
                <!-- Card Header - Dropdown -->
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Product Register</h6>
                </div>
                <!-- Card Body -->
                <div class="card-body">
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
<%--                            <input type="number" class="form-control" placeholder="Enter cate id" id="cate" name="cateId">--%>
                            <select class="form-control" name="cateId" id="cate">
                                <c:forEach  var="ca" items="${cate}">
                                    <option value="${ca.cateId}">${ca.cateName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary">Register</button>
                    </form>
                </div>
            </div>
        </div>


    </div>





</div>

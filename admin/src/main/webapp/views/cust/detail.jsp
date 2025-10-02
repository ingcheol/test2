
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    const cust_detail = {
        init:function(){
            $('#cust_update_btn').click(()=>{
                $('#cust_update_form').attr({"method":"post"});
                $('#cust_update_form').attr({"action":"/cust/updateimpl"});
                $('#cust_update_form').submit();
            });
            $('#cust_delete_btn').click(()=>{
                location.href='/cust/delete?id=${cust.custId}';
            });
        }
    }
    $(function(){
        cust_detail.init();
    });
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Cust Detail</h1>
    </div>

    <!-- Content Row -->

    <div class="row">

        <div class="col-xl-10 col-lg-7">
            <div class="card shadow mb-4">
                <!-- Card Header - Dropdown -->
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Customer Detail</h6>
                </div>
                <!-- Card Body -->
                <div class="card-body">
                    <form id="cust_update_form">
                        <div class="form-group">
                            <label for="id">Id:</label>
                            <input type="text" name="custId" class="form-control" value="${cust.custId}" readonly id="id">
                        </div>
                        <div class="form-group">
                            <label for="pwd">Password:</label>
                            <button id="cust_pwd_btn" class="btn btn-primary">Reset</button>
                        </div>
                        <div class="form-group">
                            <label for="name">Name:</label>
                            <input type="text" name="custName"  class="form-control" value="${cust.custName}" id="name">
                        </div>
                        <div class="form-group">
                            <label for="addr">Address:</label>
                            <input type="text" name="custAddr"  class="form-control" value="${cust.custAddr}" id="addr">
                        </div>
                    </form>
                    <button id="cust_update_btn" class="btn btn-primary">Update</button>
                    <button id="cust_delete_btn" class="btn btn-primary">Delete</button>
                </div>
            </div>
        </div>


    </div>





</div>

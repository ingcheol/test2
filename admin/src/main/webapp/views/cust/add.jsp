
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    const cust_add = {
        init:function(){
            $('#cust_add_btn').click(()=>{
                this.send();
            });
        },
        send:function(){
            $('#cust_add_form').attr('method','post');
            $('#cust_add_form').attr('action','<c:url value="/cust/addimpl"/>');
            $('#cust_add_form').submit();
        }
    }
    $(function(){
        cust_add.init();
    });
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">Cust Add</h1>
    </div>

    <!-- Content Row -->

    <div class="row">

        <div class="col-xl-10 col-lg-7">
            <div class="card shadow mb-4">
                <!-- Card Header - Dropdown -->
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Customer Register</h6>
                </div>
                <!-- Card Body -->
                <div class="card-body">
                    <form id="cust_add_form">
                        <div class="form-group">
                            <label for="id">Id:</label>
                            <input type="text" name="custId" class="form-control" placeholder="Enter id" id="id">
                        </div>
                        <div class="form-group">
                            <label for="pwd">Password:</label>
                            <input type="password" name="custPwd"  class="form-control" placeholder="Enter password" id="pwd">
                        </div>
                        <div class="form-group">
                            <label for="name">Name:</label>
                            <input type="text" name="custName"  class="form-control" placeholder="Enter name" id="name">
                        </div>
                        <div class="form-group">
                            <label for="addr">Address:</label>
                            <input type="text" name="custAddr"  class="form-control" placeholder="Enter name" id="addr">
                        </div>
                    </form>
                    <button id="cust_add_btn" class="btn btn-primary">Add</button>
                </div>
            </div>
        </div>


    </div>





</div>

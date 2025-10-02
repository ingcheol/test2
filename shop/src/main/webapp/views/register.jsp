<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
  const register = {
    init:function(){
      $('#cust_register_btn').click(()=>{
        this.send();
      });
    },
    send:function(){
      $('#cust_register_form').attr('method','post');
      $('#cust_register_form').attr('action','<c:url value="/registerimpl"/>');
      $('#cust_register_form').submit();
    }
  }
  $(function(){
    register.init();
  });
</script>

<div class="col-sm-10">
  <h2>Register Page</h2>
  <div class="row">
    <div class="col-sm-8">
      <form id="cust_register_form">
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
      <button id="cust_register_btn" class="btn btn-primary">Add</button>

    </div>
    <div class="col-sm-4">
      <p id="msg">Cust를 입력 하세요.</p>
    </div>
  </div>
</div>
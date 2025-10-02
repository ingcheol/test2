<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
  const custinfo = {
    init:function(){
      $('#update_btn').click(()=>{
        this.send();
      });
      $('#update_pwd_btn').click(()=>{
        location.href='<c:url value="/updatepwd"/> ';
      });
    },
    send:function(){
      $('#custinfo_form').attr('method','post');
      $('#custinfo_form').attr('action','<c:url value="/updatecustinfo"/>');
      $('#custinfo_form').submit();
    }
  }
  $(function(){
    custinfo.init();
  });
</script>
<div class="col-sm-10">
  <h2>CustInfo Page</h2>
  <button id="update_pwd_btn" class="btn btn-primary">비밀번호 변경</button>
  <div class="row">
    <div class="col-sm-8">
      <form id="custinfo_form">
        <div class="form-group">
          <label for="id">Id:</label>
          <input type="text" readonly value="${cust.custId}" name="custId" class="form-control" placeholder="Enter id" id="id">
        </div>
        <div class="form-group">
          <label for="pwd">Password:</label>
          <input type="password" name="custPwd"  class="form-control" placeholder="Enter password" id="pwd">
        </div>
        <div class="form-group">
          <label for="name">Name:</label>
          <input type="text" value="${cust.custName}" name="custName"  class="form-control" placeholder="Enter name" id="name">
        </div>
        <div class="form-group">
          <label for="addr">Addr:</label>
          <input type="text" value="${cust.custAddr}" name="custAddr"  class="form-control" placeholder="Enter Address" id="addr">
        </div>
      </form>
      <button id="update_btn" class="btn btn-primary">Update</button>

    </div>
    <div class="col-sm-4">
      <c:choose>
        <c:when test="${msg != null}">
          <h3>${msg}</h3>
        </c:when>
        <c:otherwise>
          <h3>당신의 회원정보 입니다.</h3>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

</div>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
  const updatepwd = {
    init:function(){
      $('#update_btn').click(()=>{
        this.send();
      });
    },
    check:function(){},
    send:function(){
      $('#updatepwd_form').attr('method','post');
      $('#updatepwd_form').attr('action','<c:url value="/updatepwdimpl"/>');
      $('#updatepwd_form').submit();
    }
  }
  $(function(){
    updatepwd.init();
  });
</script>


<div class="col-sm-10">
  <h2>PWD Update Page</h2>
  <div class="row">
    <div class="col-sm-6">
      <form id="updatepwd_form">
        <div class="form-group">
          <label for="pwd">Current Password:</label>
          <input type="password"  name="pwd" class="form-control" placeholder="Enter password" id="pwd">
        </div>
        <div class="form-group">
          <label for="new_pwd">New Password:</label>
          <input type="password" name="new_pwd" class="form-control" placeholder="Enter new password" id="new_pwd">
        </div>
      </form>
      <button id="update_btn" class="btn btn-primary">UPDATE</button>
    </div>
    <div class="col-sm-6">
      <c:choose>
        <c:when test="${msg != null}">
          <h3>${msg}</h3>
        </c:when>
        <c:otherwise>
          <h3>패스워드를 수정 하세요!</h3>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

</div>

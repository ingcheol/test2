
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<script>
    $(function(){

    });
</script>

<!-- Begin Page Content -->
<div class="container-fluid">

    <!-- Page Heading -->
    <h1 class="h3 mb-2 text-gray-800">Tables</h1>

    <!-- DataTales Example -->
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">Customer Select</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>NAME</th>
                        <th>Register Date</th>
                        <th>Update Date</th>
                    </tr>
                    </thead>
                    <tfoot>
                    <tr>
                        <th>ID</th>
                        <th>NAME</th>
                        <th>Register Date</th>
                        <th>Update Date</th>
                    </tr>
                    </tfoot>
                    <tbody>
                    <c:forEach var="c" items="${clist}">
                        <tr>
                            <td><a href="<c:url value="/cust/detail?id=${c.custId}"/>">${c.custId}</a></td>
                            <td>${c.custName}</td>
                            <td>
                                <fmt:parseDate value="${ c.custRegdate }"
                                               pattern="yyyy-MM-dd'T'HH:mm" var="parsedDateTime" type="both" />
                                <fmt:formatDate pattern="yyyy년MM월dd일 HH:mm" value="${ parsedDateTime }" />
                            </td>
                            <td>
                                <fmt:parseDate value="${ c.custUpdate }"
                                               pattern="yyyy-MM-dd'T'HH:mm" var="parsedDateTime" type="both" />
                                <fmt:formatDate pattern="yyyy년MM월dd일 HH:mm" value="${ parsedDateTime }" />
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>
<!-- /.container-fluid -->

<!-- Page level plugins -->
<script src="/vendor/datatables/jquery.dataTables.min.js"></script>
<script src="/vendor/datatables/dataTables.bootstrap4.min.js"></script>

<!-- Page level custom scripts -->
<script src="/js/demo/datatables-demo.js"></script>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .admin-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }

    .admin-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 30px;
        border-radius: 10px;
        margin-bottom: 30px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    .admin-header h2 {
        margin: 0;
        font-size: 28px;
    }

    .admin-header p {
        margin: 10px 0 0 0;
        opacity: 0.9;
    }

    .search-box {
        background: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }

    .search-box input {
        width: 300px;
        padding: 10px 15px;
        border: 2px solid #e0e0e0;
        border-radius: 5px;
        font-size: 14px;
        transition: border-color 0.3s;
    }

    .search-box input:focus {
        outline: none;
        border-color: #667eea;
    }

    .search-box button {
        padding: 10px 25px;
        background: #667eea;
        color: white;
        border: none;
        border-radius: 5px;
        margin-left: 10px;
        cursor: pointer;
        font-size: 14px;
        transition: background 0.3s;
    }

    .search-box button:hover {
        background: #5568d3;
    }

    .chat-table-container {
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        overflow: hidden;
    }

    .chat-table {
        width: 100%;
        border-collapse: collapse;
    }

    .chat-table thead {
        background: #f8f9fa;
    }

    .chat-table th {
        padding: 15px;
        text-align: left;
        font-weight: 600;
        color: #495057;
        border-bottom: 2px solid #dee2e6;
    }

    .chat-table td {
        padding: 15px;
        border-bottom: 1px solid #dee2e6;
        color: #212529;
    }

    .chat-table tbody tr:hover {
        background: #f8f9fa;
        transition: background 0.2s;
    }

    .chat-table tbody tr:last-child td {
        border-bottom: none;
    }

    .message-cell {
        max-width: 400px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .sender-badge, .receiver-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 15px;
        font-size: 13px;
        font-weight: 500;
    }

    .sender-badge {
        background: #e3f2fd;
        color: #1976d2;
    }

    .receiver-badge {
        background: #f3e5f5;
        color: #7b1fa2;
    }

    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-top: 30px;
        gap: 10px;
    }

    .pagination a, .pagination span {
        padding: 8px 15px;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        text-decoration: none;
        color: #495057;
        transition: all 0.3s;
    }

    .pagination a:hover {
        background: #667eea;
        color: white;
        border-color: #667eea;
    }

    .pagination .active {
        background: #667eea;
        color: white;
        border-color: #667eea;
        font-weight: 600;
    }

    .pagination .disabled {
        opacity: 0.5;
        cursor: not-allowed;
        pointer-events: none;
    }

    .stats {
        display: flex;
        gap: 15px;
        margin-top: 15px;
    }

    .stat-item {
        background: rgba(255,255,255,0.2);
        padding: 10px 20px;
        border-radius: 8px;
    }

    .stat-item strong {
        font-size: 18px;
    }

    .no-data {
        text-align: center;
        padding: 50px;
        color: #6c757d;
        font-size: 16px;
    }

    .timestamp {
        color: #6c757d;
        font-size: 13px;
    }
</style>

<div class="admin-container">
    <div class="admin-header">
        <div class="stats">
            <div class="stat-item">
                채팅 횟수: <strong>${totalChats}</strong>
            </div>
            <div class="stat-item">
                페이징처리: <strong>${currentPage} / ${totalPages}</strong>
            </div>
        </div>
    </div>

    <div class="search-box">
        <form action="/admin" method="get">
            <input type="text" name="userId" placeholder="사용자 ID로 검색..." value="${userId}">
            <button type="submit">검색</button>
            <c:if test="${not empty userId}">
                <a href="/admin" style="margin-left: 10px; color: #667eea; text-decoration: none;">✕ 초기화</a>
            </c:if>
        </form>
    </div>

    <div class="chat-table-container">
        <c:choose>
            <c:when test="${not empty admin}">
                <table class="chat-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>발신자</th>
                        <th>수신자</th>
                        <th>메시지</th>
                        <th>전송일시</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${admin}" var="chat">
                        <tr>
                            <td>${chat.chatId}</td>
                            <td>
                                <span class="sender-badge">${chat.senderId}</span>
                            </td>
                            <td>
                                <span class="receiver-badge">${chat.receiverId}</span>
                            </td>
                            <td class="message-cell" title="${chat.message}">
                                    ${chat.message}
                            </td>
                            <td class="timestamp">
                                <fmt:formatDate value="${chat.regdate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <c:if test="${totalPages > 1}">
                    <div class="pagination">
                        <c:choose>
                            <c:when test="${currentPage > 1}">
                                <a href="?page=${currentPage - 1}<c:if test='${not empty userId}'>&userId=${userId}</c:if>">
                                    이전
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="disabled">이전</span>
                            </c:otherwise>
                        </c:choose>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage}">
                                    <span class="active">${i}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?page=${i}<c:if test='${not empty userId}'>&userId=${userId}</c:if>">
                                            ${i}
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a href="?page=${currentPage + 1}<c:if test='${not empty userId}'>&userId=${userId}</c:if>">
                                    다음
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="disabled">다음</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="no-data">
                    <p>채팅 내역이 없습니다</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
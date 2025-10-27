<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Spring AI 문서 관리 시스템</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    .tab-button {
      padding: 10px 20px;
      border: none;
      background-color: #f8f9fa;
      cursor: pointer;
      border-radius: 5px;
      margin-right: 5px;
      font-weight: 500;
    }
    .tab-button.active {
      background: linear-gradient(to right, #3b82f6, #6366f1);
      color: white;
    }
    .tab-content {
      display: none;
    }
    .tab-content.active {
      display: block;
    }
    .result-item {
      border: 1px solid #dee2e6;
      border-radius: 8px;
      padding: 15px;
      margin-bottom: 10px;
      background-color: #f8f9fa;
    }
    #spinner {
      visibility: hidden;
    }
    body {
      background-color: #f5f5f5;
      padding: 20px;
    }
    .doc-item {
      position: relative;
    }
    .delete-btn {
      position: absolute;
      top: 5px;
      right: 5px;
      padding: 2px 8px;
      font-size: 12px;
    }
  </style>
</head>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  let ai1 = {
    currentTab: 'upload',

    init: function() {
      let self = this;

      document.getElementById('send').addEventListener('click', function() {
        self.send();
      });
      document.getElementById('delAll').addEventListener('click', function() {
        self.deleteAll();
      });
      document.getElementById('queryBtn').addEventListener('click', function() {
        self.queryRAG();
      });
      document.getElementById('summaryBtn').addEventListener('click', function() {
        self.generateSummary();
      });
      document.getElementById('keywordBtn').addEventListener('click', function() {
        self.extractKeywords();
      });
      document.getElementById('compareBtn').addEventListener('click', function() {
        self.compareDocuments();
      });

      let tabs = document.querySelectorAll('.tab-button');
      for (let i = 0; i < tabs.length; i++) {
        tabs[i].addEventListener('click', function() {
          let tabId = this.getAttribute('data-tab');
          self.switchTab(tabId);
        });
      }

      document.getElementById('spinner').style.visibility = 'hidden';
      this.loadDocuments();
    },

    switchTab: function(tabId) {
      let buttons = document.querySelectorAll('.tab-button');
      let contents = document.querySelectorAll('.tab-content');

      for (let i = 0; i < buttons.length; i++) {
        buttons[i].classList.remove('active');
      }
      for (let j = 0; j < contents.length; j++) {
        contents[j].classList.remove('active');
      }

      document.querySelector('[data-tab="' + tabId + '"]').classList.add('active');
      document.getElementById(tabId).classList.add('active');
      this.currentTab = tabId;
    },

    send: function() {
      let self = this;
      let type = document.getElementById('type').value;
      if (!type) {
        alert("문서 종류를 선택해야 합니다.");
        return;
      }
      let attach = document.getElementById("attach").files[0];
      if (!attach) {
        alert("문서 파일을 선택해야 합니다.");
        return;
      }
      document.getElementById('spinner').style.visibility = 'visible';

      let formData = new FormData();
      formData.append("type", type);
      formData.append("attach", attach);

      fetch('/api/ai4/txt-pdf-docx-etl', {
        method: "POST",
        body: formData
      }).then(function(response) {
        let uuid = self.makeUi("result");
        let reader = response.body.getReader();
        let decoder = new TextDecoder("utf-8");
        let content = "";

        function processStream() {
          return reader.read().then(function(result) {
            if (result.done) {
              self.loadDocuments();
              document.getElementById('spinner').style.visibility = 'hidden';
              return;
            }
            let text = decoder.decode(result.value);
            content = content + text;
            document.getElementById(uuid).innerHTML = content;
            return processStream();
          });
        }

        return processStream();
      }).catch(function(error) {
        console.error('업로드 오류:', error);
        alert('업로드 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    deleteAll: function() {
      if (!confirm('정말로 모든 문서를 삭제하시겠습니까?')) {
        return;
      }
      document.getElementById('spinner').style.visibility = 'visible';

      fetch('/api/ai4/rag-clear').then(function(response) {
        return response.text();
      }).then(function(result) {
        alert(result);
        document.getElementById('result').innerHTML = '';
        document.getElementById('docList').innerHTML = '';
        document.getElementById('queryType').innerHTML = '<option value="">선택하세요</option>';
        document.getElementById('summarySource').innerHTML = '<option value="">선택하세요</option>';
        document.getElementById('compareSource1').innerHTML = '<option value="">선택하세요</option>';
        document.getElementById('compareSource2').innerHTML = '<option value="">선택하세요</option>';
        document.getElementById('spinner').style.visibility = 'hidden';
      }).catch(function(error) {
        console.error('삭제 중 오류:', error);
        alert('삭제 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    deleteDocument: function(source) {
      let self = this;
      if (!confirm('정말로 "' + source + '" 문서를 삭제하시겠습니까?')) {
        return;
      }
      document.getElementById('spinner').style.visibility = 'visible';

      fetch('/api/ai4/documents/source/' + encodeURIComponent(source), {
        method: 'DELETE'
      }).then(function(response) {
        return response.text();
      }).then(function(result) {
        alert(result);
        document.getElementById('result').innerHTML = '';
        self.loadDocuments();
        document.getElementById('spinner').style.visibility = 'hidden';
      }).catch(function(error) {
        console.error('문서 삭제 중 오류:', error);
        alert('문서 삭제 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    loadDocuments: function() {
      let self = this;
      fetch('/api/ai4/documents').then(function(response) {
        return response.json();
      }).then(function(data) {
        let docListHtml = '';
        let querySelect = document.getElementById('queryType');
        let summarySelect = document.getElementById('summarySource');
        let compareSelect1 = document.getElementById('compareSource1');
        let compareSelect2 = document.getElementById('compareSource2');

        querySelect.innerHTML = '<option value="">선택하세요</option>';
        summarySelect.innerHTML = '<option value="">선택하세요</option>';
        compareSelect1.innerHTML = '<option value="">선택하세요</option>';
        compareSelect2.innerHTML = '<option value="">선택하세요</option>';

        if (data && data.length > 0) {
          const groupedDocs = data.reduce((acc, doc) => {
            acc[doc.type] = acc[doc.type] || [];
            acc[doc.type].push(doc);
            return acc;
          }, {});

          for (const type in groupedDocs) {
            const docsInGroup = groupedDocs[type];
            docListHtml += '<div class="col-12 mb-3">' +
                    '<h5>' + type.toUpperCase() + ' (' + docsInGroup.length + '개)</h5>' +
                    '<hr class="mt-1 mb-2">' +
                    '</div>';

            docsInGroup.forEach(doc => {
              docListHtml += '<div class="col-md-4 mb-2">' +
                      '<div class="border p-2 rounded bg-light h-100 doc-item">' +
                      '<button class="btn btn-danger btn-sm delete-btn" onclick="ai1.deleteDocument(\'' + doc.source + '\')">×</button>' +
                      '<strong class="text-primary d-block text-truncate" title="' + doc.source + '">' + doc.source + '</strong>' +
                      '</div>' +
                      '</div>';

              let queryOption = document.createElement('option');
              queryOption.value = doc.source;
              queryOption.text = doc.source;
              querySelect.add(queryOption);

              let summaryOption = document.createElement('option');
              summaryOption.value = doc.source;
              summaryOption.text = doc.source;
              summarySelect.add(summaryOption);

              let compare1Option = document.createElement('option');
              compare1Option.value = doc.source;
              compare1Option.text = doc.source;
              compareSelect1.add(compare1Option);

              let compare2Option = document.createElement('option');
              compare2Option.value = doc.source;
              compare2Option.text = doc.source;
              compareSelect2.add(compare2Option);
            });
          }
        } else {
          docListHtml = '<div class="col-12 text-center text-muted">저장된 문서가 없습니다.</div>';
        }
        document.getElementById('docList').innerHTML = docListHtml;
      }).catch(function(error) {
        console.error('문서 목록 로드 실패', error);
      });
    },

    queryRAG: function() {
      let self = this;
      let source = document.getElementById('queryType').value;
      let question = document.getElementById('queryInput').value;

      if (!source) {
        alert("문서명을 선택해야 합니다.");
        return;
      }
      if (!question) {
        alert("질문을 입력해야 합니다.");
        return;
      }

      document.getElementById('spinner').style.visibility = 'visible';

      const formData = new FormData();
      formData.append('source', source);
      formData.append('question', question);

      fetch('/api/ai4/rag-chat', {
        method: 'POST',
        body: formData
      }).then(function(response) {
        if (!response.ok) {
          alert('질의 중 서버에서 오류가 발생했습니다. 상태: ' + response.status);
          document.getElementById('spinner').style.visibility = 'hidden';
          return;
        }
        let uuid = self.makeUi("result");
        let reader = response.body.getReader();
        let decoder = new TextDecoder("utf-8");
        let content = "";

        function processStream() {
          return reader.read().then(function(result) {
            if (result.done) {
              document.getElementById('spinner').style.visibility = 'hidden';
              return;
            }
            let text = decoder.decode(result.value);
            content = content + text;
            document.getElementById(uuid).innerHTML = content;
            return processStream();
          });
        }

        return processStream();
      }).catch(function(error) {
        console.error('질의 오류:', error);
        alert('질의 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    generateSummary: function() {
      let self = this;
      let source = document.getElementById('summarySource').value;
      if (!source) {
        alert("문서명을 선택해야 합니다.");
        return;
      }

      document.getElementById('spinner').style.visibility = 'visible';

      fetch('/api/ai4/summary?source=' + encodeURIComponent(source)).then(function(response) {
        let uuid = self.makeUi("result");
        let reader = response.body.getReader();
        let decoder = new TextDecoder("utf-8");
        let content = "";

        function processStream() {
          return reader.read().then(function(result) {
            if (result.done) {
              document.getElementById('spinner').style.visibility = 'hidden';
              return;
            }
            let text = decoder.decode(result.value);
            content = content + text;
            document.getElementById(uuid).innerHTML = content;
            return processStream();
          });
        }

        return processStream();
      }).catch(function(error) {
        console.error('요약 오류:', error);
        alert('요약 생성 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    extractKeywords: function() {
      let self = this;
      let source = document.getElementById('summarySource').value;
      if (!source) {
        alert("문서명을 선택해야 합니다.");
        return;
      }

      document.getElementById('spinner').style.visibility = 'visible';

      fetch('/api/ai4/keywords?source=' + encodeURIComponent(source)).then(function(response) {
        return response.text();
      }).then(function(result) {
        let uuid = self.makeUi("result");
        document.getElementById(uuid).innerHTML = result;
        document.getElementById('spinner').style.visibility = 'hidden';
      }).catch(function(error) {
        console.error('키워드 추출 오류:', error);
        alert('키워드 추출 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    compareDocuments: function() {
      let self = this;
      let source1 = document.getElementById('compareSource1').value;
      let source2 = document.getElementById('compareSource2').value;

      if (!source1 || !source2) {
        alert("비교할 두 가지 문서를 모두 선택해야 합니다.");
        return;
      }
      if (source1 === source2) {
        alert("동일한 문서는 비교할 수 없습니다.");
        return;
      }

      document.getElementById('spinner').style.visibility = 'visible';

      fetch('/api/ai4/compare?source1=' + encodeURIComponent(source1) + '&source2=' + encodeURIComponent(source2)).then(function(response) {
        let uuid = self.makeUi("result");
        let reader = response.body.getReader();
        let decoder = new TextDecoder("utf-8");
        let content = "";

        function processStream() {
          return reader.read().then(function(result) {
            if (result.done) {
              document.getElementById('spinner').style.visibility = 'hidden';
              return;
            }
            let text = decoder.decode(result.value);
            content = content + text;
            document.getElementById(uuid).innerHTML = content;
            return processStream();
          });
        }

        return processStream();
      }).catch(function(error) {
        console.error('문서 비교 오류:', error);
        alert('문서 비교 중 오류가 발생했습니다.');
        document.getElementById('spinner').style.visibility = 'hidden';
      });
    },

    makeUi: function(target) {
      let uuid = "id-" + Math.random().toString(36).substr(2, 9);
      let timestamp = new Date().toLocaleTimeString();

      let aForm = '<div class="result-item">';
      aForm = aForm + '<div class="d-flex">';
      aForm = aForm + '<div class="flex-grow-1">';
      aForm = aForm + '<div class="d-flex justify-content-between align-items-center mb-2">';
      aForm = aForm + '<h6 class="mb-0">🤖 GPT4</h6>';
      aForm = aForm + '<small class="text-muted">' + timestamp + '</small>';
      aForm = aForm + '</div>';
      aForm = aForm + '<pre id="' + uuid + '" style="white-space: pre-wrap; margin: 0; font-family: inherit;"></pre>';
      aForm = aForm + '</div>';
      aForm = aForm + '<div class="ms-3"><div style="width:60px;height:60px;background:linear-gradient(135deg,#3b82f6,#6366f1);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:24px;font-weight:bold;">AI</div></div>';
      aForm = aForm + '</div>';
      aForm = aForm + '</div>';

      let resultDiv = document.getElementById(target);
      resultDiv.insertAdjacentHTML('afterbegin', aForm);
      return uuid;
    }
  };

  document.addEventListener('DOMContentLoaded', function() {
    ai1.init();
  });
</script>
<body>

<div class="container">
  <div class="col-sm-12">
    <h2 class="mb-4">Spring AI 문서 관리 시스템</h2>

    <div class="mb-3">
      <button class="tab-button active" data-tab="upload">문서 업로드</button>
      <button class="tab-button" data-tab="query">RAG 질의</button>
      <button class="tab-button" data-tab="summary">요약/키워드/비교</button>
    </div>

    <div id="upload" class="tab-content active">
      <div class="card mb-3">
        <div class="card-body">
          <h5 class="card-title">문서 업로드 및 벡터화</h5>
          <div class="row">
            <div class="input-group p-2">
              <span class="input-group-text">구분</span>
              <select id="type" class="form-select">
                <option value="">문서 종류 선택</option>
                <option value="pdf">PDF 문서</option>
                <option value="docx">Word 문서 (DOCX)</option>
                <option value="txt">텍스트 문서 (TXT)</option>
              </select>
            </div>
            <div class="col-sm-10">
              <span class="input-group-text">문서</span>
              <input id="attach" class="form-control" type="file" accept=".txt,.pdf,.doc,.docx"/>
            </div>
            <div class="col-sm-2">
              <button type="button" class="btn btn-primary w-100" id="send">Send</button>
            </div>
            <div class="col-sm-12 mt-2">
              <button type="button" class="btn btn-danger w-100" id="delAll">전체 삭제</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div id="query" class="tab-content">
      <div class="card mb-3">
        <div class="card-body">
          <h5 class="card-title">RAG 기반 질의응답</h5>
          <div class="mb-3">
            <label class="form-label">문서명 선택</label>
            <select id="queryType" class="form-select">
              <option value="">선택하세요</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label">질문</label>
            <textarea id="queryInput" class="form-control" rows="4" placeholder="문서에 대해 질문하세요..."></textarea>
          </div>
          <button type="button" class="btn btn-primary" id="queryBtn">질의 실행</button>
        </div>
      </div>
    </div>

    <div id="summary" class="tab-content">
      <div class="card mb-3">
        <div class="card-body">
          <h5 class="card-title">문서 요약 및 키워드 추출</h5>
          <div class="mb-3">
            <label class="form-label">문서명 선택</label>
            <select id="summarySource" class="form-select">
              <option value="">선택하세요</option>
            </select>
          </div>
          <div class="d-flex gap-2">
            <button type="button" class="btn btn-primary flex-fill" id="summaryBtn">3줄 요약</button>
            <button type="button" class="btn btn-info flex-fill" id="keywordBtn">키워드 추출</button>
          </div>
        </div>
      </div>

      <div class="card mb-3 mt-4">
        <div class="card-body">
          <h5 class="card-title">문서 비교 분석</h5>
          <div class="row mb-3">
            <div class="col-md-6">
              <label class="form-label">첫 번째 문서명</label>
              <select id="compareSource1" class="form-select">
                <option value="">선택하세요</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">두 번째 문서명</label>
              <select id="compareSource2" class="form-select">
                <option value="">선택하세요</option>
              </select>
            </div>
          </div>
          <button type="button" class="btn btn-success w-100" id="compareBtn">비교 실행</button>
        </div>
      </div>
    </div>

    <div class="mb-3">
      <button class="btn btn-primary" disabled>
        <span class="spinner-border spinner-border-sm" id="spinner"></span>
        Loading..
      </button>
    </div>

    <div id="result" class="container p-3 my-3 border rounded" style="overflow: auto; width: auto; height: 400px; background-color: #ffffff;">
      <div class="text-center text-muted py-5">
        <p>결과가 여기에 표시됩니다.</p>
      </div>
    </div>

    <div class="card mt-4">
      <div class="card-header">
        <h5 class="mb-0">저장된 문서 목록</h5>
      </div>
      <div class="card-body">
        <div class="row" id="docList">
          <div class="col-12 text-center text-muted">문서를 업로드하면 여기에 표시됩니다.</div>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>
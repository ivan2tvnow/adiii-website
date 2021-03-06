<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Adiii</title>
  <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
  <link rel="stylesheet" type="text/css" href="${resource(dir: "css", file: "bootstrap.css")}" />
  <link rel="stylesheet" type="text/css" href="${resource(dir: "css", file: "daterangepicker.css")}" />
  <style type="text/css">
      header h1{
          font-family: 'Lily Script One', cursive;
          text-decoration: none;
          line-height: 70px;
      }
      .row{
          margin-top: 5px;
          margin-bottom: 5px;
      }
      .table{
          margin-top: 8px;
          margin-bottom: 8px;
      }
      .table th {
          text-align: center;
      }
      .table td {
          text-align: center;
      }
      .nav-tab{
          font-size: 18px;
          padding: 4px;
      }
      .current_page{
          font-size: 18px;
      }
  </style>
</head>
<body>
<div class="navbar navbar-static-top">
    <div class="navbar-inner">
        <div class="container">
            <ul class="pull-right nav">
                <sec:ifNotLoggedIn>
                    <li><a href="${createLink(controller: "login", action: "auth")}">登入</a></li>
                    <li><a href="${createLink(controller: "user", action: "signup")}">註冊</a></li>
                </sec:ifNotLoggedIn>
                <sec:ifLoggedIn>
                    <li><a href="${createLink(controller: "user", action: "account")}">您好，<sec:username /></a></li>
                    <li><a href="${createLink(controller: "logout")}">登出</a></li>
                </sec:ifLoggedIn>
            </ul>
        </div>
    </div>
</div>
  <header class="">
      <div class="container">
          <h1><a class="brand" href="${createLink(controller: "adiii")}">Adiii</a></h1>
          <ul class="nav nav-pills">
              <li class="active"><a class="nav-tab" href="${createLink(controller: "advertiser", action: "index")}">廣告活動</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "reports")}">報告</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "account")}">帳戶資訊</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "support")}">技術支援</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "demo")}">呈現測試</a></li>
          </ul>
      </div>
  </header>
  <div class="container">
    <g:form controller="campaign" action="select" method="post" id="campaign_form" class="form-horizontal">
    <div id="row">
        <div class="well">
            <h2>廣告活動</h2>
            <span>您目前共有${campaignCount}個廣告活動</span>
        </div>
        <div class="well">

            <a href="${createLink(controller: 'advertiser', action: 'addcampaign')}" class="btn btn-primary">建立新廣告活動</a>
            <g:if test="${campaigns.size() <= 0}">
                <a href="#" class="btn btn-primary disabled">進行投放</a>
            </g:if>
            <g:else>
                <input type="submit" name="submit" class="btn btn-primary" value="進行投放"/>
            </g:else>
            <g:if test="${campaigns.size() <= 0}">
                <a href="#" class="btn btn-primary disabled">暫停投放</a>
            </g:if>
            <g:else>
                <input type="submit" name="submit" class="btn btn-primary" value="暫停投放"/>
            </g:else>
            <g:if test="${campaigns.size() <= 0}">
                <a href="#" class="btn btn-danger disabled">刪除廣告</a>
            </g:if>
            <g:else>
                <input type="submit" name="submit" class="btn btn-danger" value="刪除廣告"/>
            </g:else>

            <div id="report_range" class="pull-right" style="background: #fff; cursor: pointer; padding: 5px 10px; border: 1px solid #ccc">
                <i class="icon-calendar icon-large"></i>
                <span></span> <b class="caret" style="margin-top: 8px"></b>
            </div>

            <table class="table table-hover table-striped">
                <thead>
                <tr>
                    <th><input id="check_all" type="checkbox"></th>
                    <th>活動名稱</th>
                    <th>活動ID</th>
                    <th>狀態</th>
                    <th>每日預算</th>
                    <th>投放次數</th>
                    <th>點擊次數</th>
                    <th>CTR</th>
                </tr>
                </thead>
                <tbody>
                <g:if test="${campaigns.size() <= 0}">
                    <tr>
                        <td colspan="8">
                            <div class="well well-large">
                                您目前沒有任何廣告活動，請按下上方連結以新增廣告。
                            </div>
                        </td>
                    </tr>
                </g:if>
                <g:else>
                    <g:each in="${campaigns}" var="campaign">
                        <tr>
                            <td style="vertical-align:middle"><g:checkBox id="check${campaign.id}" name="campaign.${campaign.id}" value="on" checked="unchecked" /></td>
                            <td><a href="${createLink(controller: 'advertiser', action: 'campaign', id: "${campaign.id}")}"><strong class="text-info">${campaign.name}</strong></a>
                                <a id="" class="btn btn-mini btn-info pull-right" href="${createLink(controller: 'campaign', action: 'edit', id: "${campaign.id}")}">
                                    <i class="icon-pencil icon-white"></i>
                                </a>
                                <g:if test="${campaign.creatives.size() <= 0}">
                                    (無廣告內容)
                                </g:if>
                                <g:else>
                                    <a class="btn btn-mini btn-danger pull-right" href="${createLink(controller: "api", action: "search", params: [apiKey: "FWFTKK0CI", adId: campaign.id])}">VAST</a>
                                </g:else>
                            </td>
                            <td>${campaign.id}</td>
                            <g:if test="${campaign.status == "DRAFT"}">
                                <td><strong class="muted">草稿</strong></td>
                            </g:if>
                            <g:elseif test="${campaign.status == "READY"}">
                                <td><strong class="text-info">尚未投放</strong></td>
                            </g:elseif>
                            <g:elseif test="${campaign.status == "START"}">
                                <td><strong class="text-success">投放中</strong></td>
                            </g:elseif>
                            <g:elseif test="${campaign.status == "PAUSE"}">
                                <td><strong class="text-warning">暫停中</strong></td>
                            </g:elseif>
                            <g:elseif test="${campaign.status == "END"}">
                                <td><strong class="text-error">已結束</strong></td>
                            </g:elseif>
                            <td>${campaign.dailyBudget} 點</td>
                            <td>${statistics[campaign.id].impression}</td>
                            <td>${statistics[campaign.id].click}</td>
                            <g:if test="${statistics[campaign.id].impression > 0}">
                                <td>${statistics[campaign.id].click / statistics[campaign.id].impression * 1000}‰</td>
                            </g:if>
                            <g:else>
                                <td>0‰</td>
                            </g:else>
                        </tr>
                    </g:each>
                </g:else>
                </tbody>
            </table>
            <div class="pagination pagination-right">
                <ul>
                    <li><a href="#" onclick="changePage(1);">第一頁</a></li>
                    <g:if test="${currentPage > 1}">
                        <li><a href="#" onclick="changePage(${currentPage - 1});">上一頁</a></li>
                    </g:if>
                    <g:each in="${pageList}" var="page">
                        <g:if test="${page == currentPage}">
                            <li class="current_page"><a href="#">${page}</a></li>
                        </g:if>
                        <g:else>
                            <li><a href="#" onclick="changePage(${page});">${page}</a></li>
                        </g:else>
                    </g:each>
                    <g:if test="${currentPage < totalPage}">
                        <li><a href="#" onclick="changePage(${currentPage + 1});">下一頁</a></li>
                    </g:if>
                    <li><a href="#" onclick="changePage(${totalPage});">最終頁</a></li>
                </ul>
            </div>
        </div>
    </div>
    </g:form>
</div>
<footer class="footer">
    <div class="container">
    </div>
</footer>
<script type="text/javascript" src="http://code.jquery.com/jquery.js"></script>
<script type="text/javascript" src="${resource(dir: "js", file: "bootstrap.min.js")}"></script>
<script type="text/javascript" src="${resource(dir: "js", file: "moment.min.js")}"></script>
<script type="text/javascript" src="${resource(dir: "js", file: "daterangepicker.js")}"></script>
<script type="text/javascript">
    var current_page = ${currentPage};
    var start_date = "${startDate.format('yyyy-MM-dd')}";
    var end_date = "${endDate.format('yyyy-MM-dd')}";

    $(document).ready(function() {
        $('#report_range').daterangepicker(
                {
                    ranges: {
                        '至今': [new Date('01/01/2012'), new Date()],
                        '今天': [new Date(), new Date()],
                        '昨天': [moment().subtract('days', 1), moment().subtract('days', 1)],
                        '最近7天': [moment().subtract('days', 6), new Date()],
                        '最近30天': [moment().subtract('days', 29), new Date()]
                    },
                    opens: 'left',
                    format: 'MM/DD/YYYY',
                    separator: ' to ',
                    startDate: new Date(start_date),
                    endDate: new Date(end_date),
                    minDate: '01/01/2012',
                    maxDate: '12/31/2014',
                    locale: {
                        applyLabel: '確定',
                        clearLabel: "清除",
                        fromLabel: '從',
                        toLabel: '到',
                        customRangeLabel: '自定期間',
                        weekLabel: '週',
                        daysOfWeek: ['日', '一', '二', '三', '四', '五','六'],
                        monthNames: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
                        firstDay: 1
                    },
                    showWeekNumbers: true,
                    buttonClasses: ['btn-danger'],
                    dateLimit: false
                },
                function(start, end) {
                    $('#report_range span').html(start.format('YYYY/MM/DD') + ' - ' + end.format('YYYY/MM/DD'));
                    start_date = start.format('YYYY-MM-DD');
                    end_date = end.format('YYYY-MM-DD');
                    current_page = 1;
                    reloadPage();
                }
        );
        //Set the initial state of the picker label
        $('#report_range span').html(start_date + ' - ' + end_date);
    });

    $('#check_all').change(function() {
        if(!this.checked)
        {
            $('input').attr('checked', false);
        }
        else
        {
            $('input').attr('checked', true);
        }
    });

    function changePage(page) {
        current_page = page;
        reloadPage();
    }

    function reloadPage() {
        $(window.location).attr("href", "${createLink(controller: "advertiser", action: "index", absolute: true)}?page=" + current_page + "&startDate=" + start_date + "&endDate=" + end_date);
    }
</script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Adiii</title>
    <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" type="text/css" href="${resource(dir: "css", file: "bootstrap.css")}"/>
    <link rel="stylesheet" type="text/css" href="${resource(dir: "css", file: "daterangepicker.css")}"/>
    <style type="text/css">
    header h1 {
        font-family: 'Lily Script One', cursive;
        text-decoration: none;
        line-height: 70px;
    }

    .row {
        margin-top: 5px;
        margin-bottom: 5px;
    }

    .table {
        margin-top: 8px;
        margin-bottom: 8px;
    }

    .table th {
        text-align: center;
    }

    .table td {
        text-align: center;
    }

    .nav-tab {
        font-size: 18px;
        padding: 4px;
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
                    <li><a href="${createLink(controller: "user", action: "account")}">您好，<sec:username/></a></li>
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
            <li class="active"><a class="nav-tab"
                                  href="${createLink(controller: "advertiser", action: "index")}">廣告活動</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "reports")}">報告</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "account")}">帳戶資訊</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "support")}">技術支援</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "demo")}">呈現測試</a></li>
        </ul>
    </div>
</header>

<div class="container">
    <g:form url="[controller: 'creative', action: 'select', id: campaignId]" id="creative_form" class="form-horizontal">
        <div id="row">
            <div class="well">
                <h2>${campaignName}</h2>
                <span>您目前共有${creativeCount}個廣告活動</span>
            </div>

            <div class="well">
                <a href="${createLink(controller: 'advertiser', action: 'addcreative', params: [id: campaignId])}"
                   class="btn btn-primary">建立廣告內容</a>
                <a href="#" class="btn btn-primary disabled">進行投放</a>
                <a href="#" class="btn btn-primary disabled">暫停投放</a>
                <g:if test="${creatives.size() <= 0}">
                    <a href="#" class="btn btn-danger disabled">刪除內容</a>
                </g:if>
                <g:else>
                    <input type="submit" name="submit" class="btn btn-danger" value="刪除內容"/>
                </g:else>

                <div id="report_range" class="pull-right"
                     style="background: #fff; cursor: pointer; padding: 5px 10px; border: 1px solid #ccc">
                    <i class="icon-calendar icon-large"></i>
                    <span></span> <b class="caret" style="margin-top: 8px"></b>
                </div>

                <table class="table table-hover table-striped">
                    <thead>
                    <tr>
                        <th><input type="checkbox"></th>
                        <th>內容名稱</th>
                        <th>廣告ID</th>
                        <th>廣告類型</th>
                        <th>出價</th>
                        <th>投放次數</th>
                        <th>點擊次數</th>
                        <th>CTR</th>
                    </tr>
                    </thead>
                    <tbody>
                    <g:if test="${creatives.size() <= 0}">
                        <tr>
                            <td colspan="8">
                                <div class="well well-large">
                                    您目前沒有任何廣告內容，請按下上方連結以新增廣告。
                                </div>
                            </td>
                        </tr>
                    </g:if>
                    <g:else>
                        <g:each in="${creatives}" var="creative">
                            <tr>
                                <td style="vertical-align:middle"><g:checkBox id="check${creative.id}"
                                                                              name="creative.${creative.id}" value="on"
                                                                              checked="unchecked"/></td>
                                <td><a href="${createLink(controller: 'advertiser', action: 'campaign')}"><strong
                                        class="text-info">${creative.name}</strong></a>
                                    <a id="" class="btn btn-mini btn-info pull-right"
                                       href="${createLink(controller: 'creative', action: 'edit', id: "${creative.id}")}">
                                        <i class="icon-pencil icon-white"></i>
                                    </a>
                                </td>
                                <td>${creative.id}</td>
                                <g:if test="${creative instanceof adiii.VideoAdCreative}">
                                    <td>影像</td>
                                </g:if>
                                <g:elseif test="${creative instanceof adiii.MobileAdCreative}">
                                    <td>行動</td>
                                </g:elseif>
                                <td>0 點</td>
                                <td>${creative.campaign.impressions.size()}</td>
                                <td>${creative.clicks.size()}</td>
                                <g:if test="${creative.campaign.impressions.size() > 0}">
                                    <td>${creative.clicks.size() / creative.campaign.impressions.size() * 1000}‰</td>
                                </g:if>
                                <g:else>
                                    <td>0‰</td>
                                </g:else>
                            </tr>
                        </g:each>
                    </g:else>
                    </tbody>
                </table>
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
    $(document).ready(function () {


        $('#report_range').daterangepicker(
                {
                    ranges: {
                        '今天': [new Date(), new Date()],
                        '昨天': [moment().subtract('days', 1), moment().subtract('days', 1)],
                        '最近7天': [moment().subtract('days', 6), new Date()],
                        '最近30天': [moment().subtract('days', 29), new Date()]
                    },
                    opens: 'left',
                    format: 'MM/DD/YYYY',
                    separator: ' to ',
                    startDate: moment().subtract('days', 29),
                    endDate: new Date(),
                    minDate: '01/01/2012',
                    maxDate: '12/31/2013',
                    locale: {
                        applyLabel: '確定',
                        clearLabel: "清除",
                        fromLabel: '從',
                        toLabel: '到',
                        customRangeLabel: '自定期間',
                        weekLabel: '週',
                        daysOfWeek: ['日', '一', '二', '三', '四', '五', '六'],
                        monthNames: ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'],
                        firstDay: 1
                    },
                    showWeekNumbers: true,
                    buttonClasses: ['btn-danger'],
                    dateLimit: false
                },
                function (start, end) {
                    $('#report_range span').html(start.format('YYYY/MM/DD') + ' - ' + end.format('YYYY/MM/DD'));
                }
        );
        //Set the initial state of the picker label
        $('#report_range span').html(moment().subtract('days', 29).format('YYYY/MM/DD') + ' - ' + moment().format('YYYY/MM/DD'));

    });
</script>
</body>
</html>
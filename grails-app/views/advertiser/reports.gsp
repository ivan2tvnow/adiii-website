<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Adiii</title>
  <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
  <link href="${resource(dir: "css", file: "bootstrap.css")}" rel="stylesheet" media="screen">
  <style type="text/css">
  header h1{
      font-family: 'Lily Script One', cursive;
      text-decoration: none;
      line-height: 70px;
  }
  .nav-tab{
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
              <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "index")}">廣告活動</a></li>
              <li class="active"><a class="nav-tab" href="#">報告</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "account")}">帳戶資訊</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "support")}">技術支援</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "demo")}">呈現測試</a></li>
          </ul>
      </div>
  </header>
  <div class="container">
    <div id="row">
        <div class="well">
            <h2>報告</h2>
        </div>
        <div class="well">
            <div id="chart_container">

            </div>
        </div>
    </div>
</div>
<footer class="footer">
    <div class="container">
    </div>
</footer>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="<g:resource dir="js" file="bootstrap.min.js"/>"></script>
<script src="http://code.highcharts.com/highcharts.js"></script>
<script src="http://code.highcharts.com/modules/exporting.js"></script>
<script>
    $(function() {
        $('#chart_container').highcharts({
            chart: {
                type: 'line',
                marginRight: 100,
                marginBottom: 100
            },
            title: {
                text: '所有廣告投放狀況總覽',
                x: -20 //center
            },
            xAxis: {
                categories: ['2013/06/04','2013/06/05','2013/06/06','2013/06/07','2013/06/08','2013/06/09','2013/06/10',
                    '2013/06/11','2013/06/12','2013/06/13','2013/06/14','2013/06/15','2013/06/16','2013/06/17'],
                labels: {
                    y : 20, rotation: -45, align: 'right'
                }
            },
            yAxis: {
                max: 100,
                min: 0,
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'top',
                x: -10,
                y: 100,
                borderWidth: 0
            },
            series: [{
                name: '投放次數',
                data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            }, {
                name: '點擊次數',
                data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            }]
        });
    });
</script>
</body>
</html>
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
              <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "reports")}">報告</a></li>
              <li class="active"><a class="nav-tab" href="#">帳戶資訊</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "support")}">技術支援</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "demo")}">呈現測試</a></li>
          </ul>
      </div>
  </header>
  <div class="container">
    <div id="row">
        <div class="well">
            <h2>帳戶資訊</h2>
        </div>
        <div class="span8">
            <div class="well">
                <table class="table table-bordered">
                    <tbody>
                    <tr class="success"><td>姓</td><td>${advertiser.firstname}</td></tr>
                    <tr class="info"><td>名子</td><td>${advertiser.lastname}</td></tr>
                    <tr class="success"><td>信箱地址</td><td>${advertiser.email}</td></tr>
                    <sec:ifAllGranted roles="ROLE_DEVELOPER">
                        <tr class="info"><td>帳戶類型</td><td>開發商</td></tr>
                    </sec:ifAllGranted>
                    <sec:ifAllGranted roles="ROLE_ADVERTISER">
                        <tr class="info"><td>帳戶類型</td><td>廣告商</td></tr>
                    </sec:ifAllGranted>
                    <tr class="success"><td>國籍</td><td>${advertiser.country}</td></tr>
                    <tr class="info"><td>組織</td><td>${advertiser.company}</td></tr>
                    <tr class="success"><td>使用者金鑰</td><td>${advertiser.apikey}</td></tr>
                    </tbody>
                </table>
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
</body>
</html>
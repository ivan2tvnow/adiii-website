<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Adiii</title>
    <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
    <link href="${resource(dir: "css", file: "bootstrap.css")}" rel="stylesheet" media="screen">
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
                <sec:ifAllGranted roles="ROLE_ADMIN">
                    <g:link class="create" controller="auth" action="admin">帳號管理</g:link>
                </sec:ifAllGranted>
            </ul>
        </div>
    </div>
</div>
<header class="">
    <div class="container">
        <h1><a class="brand" href="${createLink(controller: "adiii")}">Adiii</a></h1>
    </div>
</header>
<g:if test='${flash.message}'>
    <script>alert("${flash.message}");</script>
</g:if>
</body>
</html>
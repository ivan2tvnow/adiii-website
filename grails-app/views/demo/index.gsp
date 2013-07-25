<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>Adiii</title>
  <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
  <link rel="stylesheet" type="text/css" href="${resource(dir: "css", file: "bootstrap.css")}" />
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
              <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "account")}">帳戶資訊</a></li>
              <li><a class="nav-tab" href="${createLink(controller: "support")}">技術支援</a></li>
              <li class="active"><a class="nav-tab" href="#">呈現測試</a></li>
          </ul>
      </div>
  </header>
  <div class="container">
    <div id="row">
        <div class="well">
            <h2>廣告呈現測試</h2>
            <form class="form-inline" onsubmit="return false;">
                <label>使用者金鑰：</label>
                <input type="text" id="api_key_text" class="input-small span4" value="TYKUOPQF2">
                <button type="submit" id="submit_button" class="btn btn-info">取得廣告內容</button>
            </form>
        </div>
        <div class="well">
            <div class="row">
                <div class="span11 well">
                    <h3>影片廣告 (VAST Response)</h3>
                    <div class="row">
                        <div id="video_panel" class="span5">
                            <iframe width="400" height="225" src="http://www.youtube.com/embed/Vpg9yizPP_g" frameborder="0" allowfullscreen></iframe>
                            <div id="ad_img_container"></div>
                        </div>
                        <div class="span5 offset1">
                            <label><strong>VAST Request URL</strong></label>
                            <input type="text" id="request_url_text" class="span5 text-info">
                            <textarea id="vast_textarea" class="span5" rows="15" cols="50"></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div  class="well">
                <h3>行動廣告</h3>
                <p></p>
            </div>
        </div>
    </div>
</div>
<footer class="footer">
    <div class="container">
    </div>
</footer>
<script type="text/javascript" src="http://code.jquery.com/jquery.js"></script>
<script type="text/javascript" src="${resource(dir: "js", file: "bootstrap.min.js")}"></script>
<script type="text/javascript">
    $(document).ready(function() {
        $('#submit_button').click(function(e){
            e.preventDefault();
            e.stopPropagation();
            favfunct();
        });
    });

    function favfunct() {
        var request = $.ajax({
            url: "${createLink(controller: "api", action: "getAd", absolute: true)}",
            type: "GET",  // TODO: this should be 'POST'
            data: { "apiKey": $("#api_key_text").val() },
            dataType: "text",
            complete: function(){
                $("#request_url_text").val(this.url);
            }
        });
        request.done(function(response) {
            $("#vast_textarea").html(response);
            var xmlDoc = $.parseXML(response);
            var $xml = $(xmlDoc);
            var imgUrl = $xml.find("StaticResource").eq(0).text();
            var adLink = $xml.find("CompanionClickThrough").eq(0).text();
            var adClick = $xml.find("CompanionClickTracking").eq(0).text();

            $("#ad_image").remove();
            $("#ad_img_container").append('<a href="'+adLink+'" onclick="secfunct(\''+adClick+'\')">' +
                  '<img id="ad_image" src="'+imgUrl+'" width="400" class="text-center img-polaroid" onerror="this.src=\'../assets/default.png\'"></a>');

            $.ajax({
                url: $xml.find("Impression").text(),
                type: "GET",
                dataType: "text",
                complete: function(){
                }
            });
        });
        request.fail(function(jqXHR, textStatus) {
            alert( "Request failed: " + textStatus );
        });
    }

    function secfunct(url) {
        var request = $.ajax({
            url: url,
            type: "GET",  // TODO: this should be 'POST'
            dataType: "text",
            complete: function(){
                alert(url);
            }
        });
        request.fail(function(jqXHR, textStatus) {
            alert( "Request failed: " + textStatus );
        });
    }
</script>
</body>
</html>
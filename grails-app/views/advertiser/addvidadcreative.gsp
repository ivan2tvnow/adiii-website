<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Adiii</title>
    <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
    <link href="<g:resource dir="css" file="bootstrap.css"/>" rel="stylesheet" media="screen">
    <style type="text/css">
    header h1{
        font-family: 'Lily Script One', cursive;
        text-decoration: none;
        line-height: 70px;
    }
    label.error{
        color: #FF0000;
        font-weight: 200;
        display: inline;
        margin-left: 5px;
    }
    .login_message {
        font-size: 20px;
        padding: 6px 25px 20px 25px;
        color: #c33;
    }
    .errorMesseage {
        color: #c33;
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
        </ul>
    </div>
</header>
<div class="container">
    <div id="row">
    <div class="well">
        <h2>建立新影片廣告內容</h2>
        <span>您目前共有 ${campaignCount} 個影片廣告活動</span>
    </div>
        <div class="well">
    <g:uploadForm url="[controller: 'videoAdCreative', action: 'save', id: campaignId]" id="creative_form" class="form-horizontal">
        <g:if test='${flash.message}'>
            <div class='login_message'>${flash.message}</div>
        </g:if>
        <fieldset>
            <legend>廣告內容資訊</legend>
            <div class="control-group">
                <label class="control-label" for="ad_name">
                    廣告名稱：<em class="red">*</em>
                </label>
                <div class="controls">
                    <g:textField name="ad_name" value="${creative.name}" required="true"/>
                    <span class="add-on">
                        <a id="ad_name_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                    <g:if test="${errorMesseage.contains("name")}"><div class="errorMesseage">請輸入正確名稱</div></g:if>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="ad_link">
                    廣告連結：<em class="red">*</em>
                </label>
                <div class="controls">
                    <g:textField class="span4" name="ad_link" value="${creative.link}" required="true"/>
                    <span class="add-on">
                        <a id="ad_link_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                    <g:if test="${errorMesseage.contains("link")}"><div class="errorMesseage">請輸入有效的連結</div></g:if>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="display_text">
                    顯示文字：<em class="red">*</em>
                </label>
                <div class="controls">
                    <g:textField class="span4" name="display_text" value="${creative.displayText}" required="true" length="48"/>
                    <span class="add-on">
                        <a id="display_text_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                    <g:if test="${errorMesseage.contains("displayText")}"><div class="errorMesseage">請輸入正確的文字</div></g:if>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="upload_file">
                    廣告圖片：<em class="red">*</em>
                </label>
                <div class="controls">
                    <input type="file" name="upload_file" accept="image/*" required="true"/>
                    <span class="add-on">
                        <a id="upload_file_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                    <g:if test="${errorMesseage.contains("imageUrl")}"><div class="errorMesseage">請輸入符合規範的圖片</div></g:if>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label" for="price">
                    出價：<em class="red">*</em>
                </label>
                <div class="controls">
                    <g:textField class="span4" name="price" required="true" value="${creative.price}" length="48"/>
                    <span class="add-on">
                        <a id="price_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                    <g:if test="${errorMesseage.contains("price")}"><div class="errorMesseage">請輸入正確的價格</div></g:if>
                </div>
            </div>
        </fieldset>
        <div class="form-actions">
            <input type="submit" class="btn btn-primary" value="儲存並完成">
            <input type="submit" class="btn" value="取消"/>
        </div>
    </g:uploadForm>
            </div>
  </div>
</div>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="${resource(dir: "js", file: "bootstrap.min.js")}"></script>
<script src="${resource(dir: "js", file: "jquery.validate.js")}"></script>
<script>
    $(function() {

    });

    $('#ad_name_info').popover({
        'trigger': 'hover',
        'content': '僅供識別之用，廣告受眾將不會看到此名稱。同一廣告活動中各廣告內容名稱必須是唯一的，此名稱最多允許輸入30個字元。'
    });
    $('#ad_link_info').popover({
        'trigger': 'hover',
        'content': '廣告受眾點擊廣告後將被導去的網路位址；請務必確認這是您希望受眾瀏覽的產品頁面。'
    });
    $('#display_text_info').popover({
        'trigger': 'hover',
        'content': '當廣告圖片無法顯示，或需要顯示代表廣告內容的文字時，將用以顯示的文字。'
    });
    $('#upload_file_info').popover({
        'trigger': 'hover',
        'content': '實際用以顯示的廣告圖片；最大檔案尺寸為500kb；並僅允許jpg、jpeg與png等圖片格式。'
    });
    $('#price_info').popover({
        'trigger': 'hover',
        'content': '廣告的單價。'
    });

    $("#creative_form").validate({
        rules:{
            ad_name:{
                required: true,
                maxlength: 30
            },
            ad_link:{
                required: true
            },
            display_text:{
                required: true,
                maxlength: 48
            },
            upload_file:{
                required: true
            },
            price:{
                required: true
            }
        },
        messages: {
            ad_name:{
                required: "此欄位為必填欄位。",
                maxlength: "廣告內容名稱不能超過30個字元。"
            },
            ad_link:{
                required: "此欄位為必填欄位。"
            },
            display_text:{
                required: "此欄位為必填欄位。",
                maxlength: "廣告內容名稱不能超過48個字元。"
            },
            upload_file:{
                required: "必須上傳廣告圖片以建立廣告內容。"
            },
            price:{
                required: "此欄位為必填欄位。"
            }
        }
    });
</script>
</body>
</html>
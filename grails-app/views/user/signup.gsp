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
    </style>
</head>
<body>
<div class="navbar navbar-static-top">
    <div class="navbar-inner">
        <div class="container">
            <ul class="pull-right nav">
                <li><a href="${createLink(controller: "user", action: "account")}">您好，Test Advertiser</a></li>
                <li><a href="${createLink(controller: "user", action: "logout")}">登出</a></li>
            </ul>
        </div>
    </div>
</div>
<header class="">
    <div class="container">
        <h1><a class="brand" href="${createLink(controller: "adiii")}">Adiii</a></h1>
    </div>
</header>
<div class="container">
    <div id="row">
        <div class="well">
            <h2>建立新帳戶</h2>
        </div>
        <div class="well">
            <g:form url="[controller: 'user', name: 'save']" id="user_form" class="form-horizontal">
                <fieldset>
                    <legend>帳戶類型</legend>

                    <label class="radio" for="advertiser">
                        <g:radio name="user_type" value="advertiser" checked="true"/>
                        廣告商
                    </label>

                    <label class="radio" for="developer">
                        <g:radio name="user_type" value="developer" disabled="true"/>
                        開發商
                    </label>
                </fieldset>
                <fieldset>
                    <legend>使用者資訊</legend>
                    <div class="control-group">
                        <label class="control-label" for="email">
                            信箱地址：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:textField name="email" required="true"/>
                            <span class="add-on">
                                <a id="email_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="passwd">
                            密碼：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:passwordField class="span4" name="passwd" value="" required="true"/>
                            <span class="add-on">
                                <a id="passwd_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="confirm">
                            確認密碼：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:passwordField class="span4" name="confirm" value="" required="true"/>
                            <span class="add-on">
                                <a id="confirm_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="firstname">
                            姓：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:textField class="span4" name="firstname" required="true" length="48"/>
                            <span class="add-on">
                                <a id="firstname_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="lastname">
                            名子：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:textField class="span4" name="lastname" required="true" length="48"/>
                            <span class="add-on">
                                <a id="lastname_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="country">
                            國籍：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:select class="span4" name="country" from="${countrylist}"/>
                            <span class="add-on">
                                <a id="country_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label" for="company">
                            組織：<em class="red">*</em>
                        </label>
                        <div class="controls">
                            <g:textField class="span4" name="company" required="true" length="48"/>
                            <span class="add-on">
                                <a id="company_info" class="btn btn-mini btn-info">
                                    <i class="icon-info-sign icon-white"></i>
                                </a>
                            </span>
                        </div>
                    </div>

                </fieldset>
                <div class="form-actions">
                    <input type="submit" class="btn btn-primary" value="儲存並完成">
                    <input type="submit" class="btn" value="取消"/>
                </div>
            </g:form>
        </div>
    </div>
</div>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="${resource(dir: "js", file: "bootstrap.min.js")}"></script>
<script src="${resource(dir: "js", file: "jquery.validate.js")}"></script>
<script>
    $(function() {

    });

    $('#email_info').popover({
        'trigger': 'hover',
        'content': '信箱作為登入憑證用。'
    });
    $('#passwd_info').popover({
        'trigger': 'hover',
        'content': '密碼，必須多於6個字元。'
    });
    $('#confirm_info').popover({
        'trigger': 'hover',
        'content': '再次輸入剛剛的密碼。'
    });
    $('#firstname_info').popover({
        'trigger': 'hover',
        'content': '輸入您的姓。'
    });
    $('#lastname_info').popover({
        'trigger': 'hover',
        'content': '輸入您的名子。'
    });
    $('#country_info').popover({
        'trigger': 'hover',
        'content': '輸入您的國籍。'
    });
    $('#company_info').popover({
        'trigger': 'hover',
        'content': '輸入您的組織。'
    });

    $("#user_form").validate({
        rules:{
            email:{
                required: true,
                maxlength: 30
            },
            passwd:{
                required: true,
                minlength: 6
            },
            confirm:{
                required: true,
                minlength: 6
            },
            firstname:{
                required: true
            },
            lastname:{
                required: true
            },
            country:{
                required: true
            },
            company:{
                required: true
            }
        },
        messages: {
            email:{
                required: "此欄位為必填欄位。",
                maxlength: "信箱長度不能超過30個字元。"
            },
            passwd:{
                required: "此欄位為必填欄位。",
                minlength: "密碼不能少於6個字元。"
            },
            confirm:{
                required: "此欄位為必填欄位。",
                minlength: "密碼不能少於6個字元。"
            },
            firstname:{
                required: "此欄位為必填欄位。"
            },
            lastname:{
                required: "此欄位為必填欄位。"
            },
            country:{
                required: "此欄位為必填欄位。"
            },
            company:{
                required: "此欄位為必填欄位。"
            }
        }
    });
</script>
</body>
</html>
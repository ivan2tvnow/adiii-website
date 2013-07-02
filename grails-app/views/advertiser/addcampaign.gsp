<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Adiii</title>
    <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
    <link href="${resource(dir: "css", file: "bootstrap.css")}" rel="stylesheet" media="screen">
    <link href="${resource(dir: "css", file: "datepicker.css")}" rel="stylesheet">
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
            <li class="active"><a class="nav-tab" href="#">廣告活動</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "reports")}">報告</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "advertiser", action: "account")}">帳戶資訊</a></li>
            <li><a class="nav-tab" href="${createLink(controller: "support")}">技術支援</a></li>
        </ul>
    </div>
</header>
<div class="container">
    <div id="row">
    <div class="well">
        <h2>建立新廣告活動</h2>
        <span>您目前共有 ${campaignCount} 個廣告活動</span>
    </div>
        <div class="well">
    <g:form controller="campaign" action="save" method="post" id="campaign_form" class="form-horizontal">
        <g:if test='${flash.message}'>
            <div class='login_message'>${flash.message}</div>
        </g:if>
        <fieldset>
            <legend>基本資訊</legend>
            <div class="control-group">
                <label for="campaign_name" class="control-label" >
                    廣告活動名稱：<em class="red">*</em>
                </label>
                <div class="controls">
                    <g:textField name="campaign_name" required="true" maxlength="30"/>
                    <span class="add-on">
                        <a id="campaign_name_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                </div>
                <span class="help-block"></span>
            </div>

            <div class="control-group">
                <label for="start_date"  class="control-label">
                    開始時間：<em class="red">*</em>
                </label>
                <div class="controls">
                    <div class="input-append date" id="start_date_datepicker" data-date="${startDate}" data-date-format="yyyy/mm/dd">
                        <g:textField class="span2" name="start_date" value="${startDate}" readonly="readonly"/>
                        <span class="add-on"><i class="icon-calendar"></i></span>
                    </div>
                    <g:select class="span1" name="start_hour" from="${hourList}" value="${selectHour}"/> : <g:select class="span1" name="start_min" from="${['00', '15', '30', '45']}"/>
                    <span class="add-on">
                        <a id="start_datetime_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                </div>
            </div>

            <div class="control-group">
                <label for="end_date" class="control-label">
                    <g:checkBox id="has_end_checkbox" name="check_end_date" checked="false" />  結束時間：
                </label>
                <div class="controls">
                    <div class="input-append date" id="end_date_datepicker" data-date="${endDate}" data-date-format="yyyy/mm/dd">
                        <g:textField id="end_date_text" class="span2" name="end_date" value="${endDate}" readonly="readonly"/>
                        <span class="add-on"><i class="icon-calendar"></i></span>
                    </div>
                    <g:select id="end_hour_select" class="span1" name="end_hour" from="${hourList}" value="23"/> : <g:select id="end_min_select" class="span1" name="end_min" from="${['14', '29', '44', '59']}" value="59"/>
                    <span class="add-on">
                        <a id="end_datetime_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                </div>
            </div>

            <div class="control-group">
                <label for="daily_budget" class="control-label">
                    每日預算 (點)：<em class="red">*</em>
                </label>
                <div class="controls">
                    <g:field class="span2" type="number" name="daily_budget" required="true" value="50" maxlength="5"/>
                    <span class="add-on">
                        <a id="daily_budget_info" class="btn btn-mini btn-info">
                            <i class="icon-info-sign icon-white"></i>
                        </a>
                    </span>
                </div>
            </div>
        </fieldset>
        <fieldset>
            <legend>廣告活動類型</legend>

            <label class="radio" for="mobile_ad">
                <g:radio name="campaign_type" value="mobile_ad" checked="true"/>
                行動裝置廣告 (如AdMob與Airpush所提供之廣告類型)
            </label>

            <label class="radio" for="video_ad">
                <g:radio name="campaign_type" value="video_ad" checked="false"/>
                影音廣告 (建立符合VAST 3.0規格之廣告內容)
            </label>
        </fieldset>
        <div class="form-actions">
            <input type="submit" class="btn btn-primary" value="儲存並繼續"/>
            <input type="submit" class="btn" value="取消"/>
        </div>
    </g:form>
            </div>
  </div>
</div>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="${resource(dir: "js", file: "bootstrap.min.js")}"></script>
<script src="${resource(dir: "js", file: "bootstrap-datepicker.js")}"></script>
<script src="${resource(dir: "js", file: "jquery.validate.js")}"></script>
<script>
    $(function() {
        $('#end_date_datepicker').attr('disabled', true);
        $('#end_hour_select').attr('disabled', true);
        $('#end_min_select').attr('disabled', true);
    });

    $('#campaign_name_info').popover({
        'trigger': 'hover',
        'content': '僅供識別之用，廣告受眾將不會看到此名稱。同一廣告商使用者帳戶中的廣告活動名稱必須是唯一的，此名稱最多允許輸入30個字元。'
    });
    $('#start_datetime_info').popover({
        'trigger': 'hover',
        'content': '預計開始投放廣告的日期與時間。'
    });
    $('#end_datetime_info').popover({
        'trigger': 'hover',
        'content': '預計結束廣告活動投放的時間；若不輸入確切時間，則廣告活動將持續進行投放。'
    });
    $('#daily_budget_info').popover({
        'trigger': 'hover',
        'content': '預計的每日廣告投放預算，以Adiii點數為單位，一點約等於新台幣一元；每日預算最多可設定為99,999點。'
    });

    var nowTemp = new Date();
    var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

    var startDatePicker = $('#start_date_datepicker').datepicker({
        onRender: function(date) {
            return date.valueOf() < now.valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function(ev) {
        if (ev.date.valueOf() > endDatePicker.date.valueOf()) {
            var newDate = new Date(ev.date);
            newDate.setDate(newDate.getDate() + 7);
            endDatePicker.setValue(newDate);
        }
        startDatePicker.hide();
        $('#end_date_datepicker')[0].focus();
    }).data('datepicker');

    var endDatePicker = $('#end_date_datepicker').datepicker({
        onRender: function(date) {
            return date.valueOf() <= startDatePicker.date.valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function(ev) {
        endDatePicker.hide();
    }).data('datepicker');

    $('#has_end_checkbox').change(function(){
        if(!this.checked)
        {
            $('#end_date_datepicker').attr('disabled', true);
            $('#end_hour_select').attr('disabled', true);
            $('#end_min_select').attr('disabled', true);
        }
        else
        {
            $('#end_date_datepicker').removeAttr('disabled');
            $('#end_hour_select').removeAttr('disabled');
            $('#end_min_select').removeAttr('disabled');
        }
    });

        $("#campaign_form").validate({
            rules:{
                campaign_name:{
                    required: true,
                    maxlength: 30
                },
                daily_budget:{
                    required:true,
                    digits:true,
                    min: 50
                }
            },
            messages: {
                campaign_name:{
                    required: "此欄位為必填欄位。",
                    maxlength: "廣告活動名稱不能超過30個字元。"
                },
                daily_budget:{
                    required: "此欄位為必填欄位。",
                    number: "請輸入合法的數字。",
                    digits: "此欄位僅能輸入整數數字。",
                    min: "每日預算至少須為50點。"
                }
            }
        });
</script>
</body>
</html>
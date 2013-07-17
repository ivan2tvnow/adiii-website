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

            <div id="chart_container" class="pull-left"></div>
            <div id="report_config">
                <fieldset>
                    <legend>顯示資訊</legend>
                    <label for="campaign_name" class="control-label" >
                        廣告活動：
                    </label>
                    <select name="campaign_name" id="campaign_name" onchange="">
                        <option value="all">顯示全部</option>
                        <g:each in="${campaignList}" var="campaign">
                            <option value="${campaign.id}">${campaign.name}</option>
                        </g:each>
                    </select>

                    <label for="campaign_name" class="control-label" >
                        內容：
                    </label>
                    <g:select name="first_content" id="first_content" from="${fistContentList}" onchange=""/>

                    <label for="sec_content" class="control-label">
                        <g:checkBox id="content_checkbox" name="content_checkbox" checked="false" /> 增加內容：
                    </label>
                    <g:select name="sec_content" id="sec_content" from="${secondContentList}" onchange=""/>

                    <label for="start_date" class="control-label" >
                        時間範圍：
                    </label>
                    <div class="input-append date" id="start_date_datepicker" data-date="${startDate}" data-date-format="yyyy-mm-dd">
                        <g:textField class="span2" name="start_date" id="start_date" value="${startDate}" readonly="readonly"/>
                        <span class="add-on"><i class="icon-calendar"></i></span>
                    </div>
                    到
                    <div class="input-append date" id="end_date_datepicker" data-date="${endDate}" data-date-format="yyyy-mm-dd">
                        <g:textField class="span2" name="end_date" id="end_date" value="${endDate}" readonly="readonly"/>
                        <span class="add-on"><i class="icon-calendar"></i></span>
                    </div>

                    <div class="form-actions">
                        <input type="button" class="btn btn-primary" value="確定" onclick="favfunct();"/>
                    </div>

                </fieldset>
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
<script src="<g:resource dir="js" file="bootstrap-datepicker.js"/>"></script>
<script src="http://code.highcharts.com/highcharts.js"></script>
<script src="http://code.highcharts.com/modules/exporting.js"></script>
<script>
    $(function() {
        $('#sec_content').attr('disabled', true);
    });

    $('#content_checkbox').change(function(){
        if(!this.checked)
        {
            $('#sec_content').attr('disabled', true);
        }
        else
        {
            $('#sec_content').removeAttr('disabled');
            setContent($('#sec_content'), $('#first_content'));
        }
    });

    $('#first_content').change(function(){
        setContent($('#first_content'), $('#sec_content'));
    });

    $('#sec_content').change(function(){
        setContent($('#sec_content'), $('#first_content'));
    });

    var nowTemp = new Date();
    var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

    var endDatePicker = $('#end_date_datepicker').datepicker({
        onRender: function(date) {
            return date.valueOf() > now.valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function(ev) {
                if (ev.date.valueOf() < startDatePicker.date.valueOf()) {
                    var newDate = new Date(ev.date);
                    newDate.setDate(newDate.getDate() - 7);
                    startDatePicker.setValue(newDate);
                }
                endDatePicker.hide();
                $('#start_date_datepicker')[0].focus();
            }).data('datepicker');

    var startDatePicker = $('#start_date_datepicker').datepicker({
        onRender: function(date) {
            return date.valueOf() >= endDatePicker.date.valueOf() ? 'disabled' : '';
        }
    }).on('changeDate', function(ev) {
                startDatePicker.hide();
            }).data('datepicker');

    function setContent(contentA, contentB) {
        if (contentA.val() == contentB.val()) {
            contentB.children().each(function(){
                if ($(this).val() != contentA.val()){
                    $(this).attr("selected","true");
                }
            });
        }
    }

    $(document).ready(function() {
        favfunct();
    });

    function favfunct() {
        var campaign_name = $('#campaign_name').val()
        var first_content = $('#first_content').val()
        var second_content = $('#sec_content').val()
        var start_date = $('#start_date').val()
        var end_date = $('#end_date').val()

        if ($('#sec_content').attr("disabled") == "disabled") {
            second_content = "";
        }

        $.ajax({
            url: "${createLink(controller: "ajaxApi", action: "getReports", absolute: true)}",
            type: "GET",
            data: { "target": campaign_name , "first": first_content, "second": second_content, "start": start_date, "end": end_date},
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function(data){
                showReport(data)
            }
        });
    }

    function showReport(data) {
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
                categories: data.date,
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
            series: data.output
        });
    }
</script>
</body>
</html>
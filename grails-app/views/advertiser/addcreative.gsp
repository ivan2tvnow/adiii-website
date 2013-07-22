<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Adiii</title>
    <link href='http://fonts.googleapis.com/css?family=Lily+Script+One' rel='stylesheet' type='text/css'>
    <link href="<g:resource dir="css" file="bootstrap.css"/>" rel="stylesheet" media="screen">
    <style type="text/css">
    header h1 {
        font-family: 'Lily Script One', cursive;
        text-decoration: none;
        line-height: 70px;
    }

    label.error {
        color: #FF0000;
        font-weight: 200;
        display: inline;
        margin-left: 5px;
    }

    .creative-table {
        word-break: keep-all;
        color: #424ccc;
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
        </ul>
    </div>
</header>

<div class="container">
    <div id="row">
        <div class="well">
            <h2>建立新廣告內容</h2>
            <span>您目前共有 ${campaignCount} 個廣告活動</span>
        </div>

        <g:if test="${successList.size() > 0}">
            <div class="alert alert-success">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <h4>通知!</h4>
                <g:each in="${successList}" var="success">廣告新增成功：${success}</g:each>
            </div>
        </g:if>

        <div class="well span8">
            <g:uploadForm url="[controller: 'creative', action: 'save', id: campaignId]" id="creative_form"
                          class="form-horizontal">
                <g:each in="${creativeList}" var="creativePair" status="i">
                    <div id="creative_field_${i}">
                        <fieldset>
                            <legend>廣告內容 ${i + 1}</legend>

                            <div class="control-group">
                                <label class="control-label" for="ad_type.${i}">
                                    廣告類別：<em class="red">*</em>
                                </label>

                                <div class="controls">
                                    <select name="ad_type.${i}" id="ad_type.${i}">
                                        <g:if test="${creativePair.creative instanceof adiii.MobileAdCreative}">
                                            <option value="video">影像廣告</option>
                                            <option value="mobile" selected="selected">行動廣告</option>
                                        </g:if>
                                        <g:else>
                                            <option value="video" selected="selected">影像廣告</option>
                                            <option value="mobile">行動廣告</option>
                                        </g:else>
                                    </select>
                                    <span class="add-on">
                                        <a id="ad_type_info" class="btn btn-mini btn-info ad_type">
                                            <i class="icon-info-sign icon-white"></i>
                                        </a>
                                    </span>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="ad_name.${i}">
                                    廣告名稱：<em class="red">*</em>
                                </label>

                                <div class="controls">
                                    <g:textField name="ad_name.${i}" id="ad_name.${i}" class="ad_name" required="true"
                                                 value="${creativePair.creative.name}"/>
                                    <span class="add-on">
                                        <a id="ad_name_info" class="btn btn-mini btn-info ad_name_info">
                                            <i class="icon-info-sign icon-white"></i>
                                        </a>
                                    </span>
                                    <g:if test="${creativePair.errorMesseage.contains("name")}"><div
                                            class="errorMesseage">請輸入正確名稱</div></g:if>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="ad_link.${i}">
                                    廣告連結：<em class="red">*</em>
                                </label>

                                <div class="controls">
                                    <g:textField class="span4 ad_link" name="ad_link.${i}" id="ad_link.${i}"
                                                 value="${creativePair.creative.link}" required="true"/>
                                    <span class="add-on">
                                        <a id="ad_link_info" class="btn btn-mini btn-info ad_link_info">
                                            <i class="icon-info-sign icon-white"></i>
                                        </a>
                                    </span>
                                    <g:if test="${creativePair.errorMesseage.contains("link")}"><div
                                            class="errorMesseage">請輸入有效的連結</div></g:if>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="display_text.${i}">
                                    顯示文字：<em class="red">*</em>
                                </label>

                                <div class="controls">
                                    <g:textField class="span4 display_text" name="display_text.${i}"
                                                 id="display_text.${i}" required="true" length="48"
                                                 value="${creativePair.creative.displayText}"/>
                                    <span class="add-on">
                                        <a id="display_text_info" class="btn btn-mini btn-info display_text_info">
                                            <i class="icon-info-sign icon-white"></i>
                                        </a>
                                    </span>
                                    <g:if test="${creativePair.errorMesseage.contains("displayText")}"><div
                                            class="errorMesseage">請輸入正確的文字</div></g:if>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="upload_file.${i}">
                                    廣告圖片：<em class="red">*</em>
                                </label>

                                <div class="controls">
                                    <input type="file" name="upload_file.${i}" id="upload_file.${i}" class="uploader"
                                           accept="image/*" required="true"/>
                                    <span class="add-on">
                                        <a id="upload_file_info" class="btn btn-mini btn-info upload_file_info">
                                            <i class="icon-info-sign icon-white"></i>
                                        </a>
                                    </span>
                                    <g:if test="${creativePair.errorMesseage.contains("imageUrl")}"><div
                                            class="errorMesseage">請輸入符合規範的圖片</div></g:if>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label" for="price.${i}">
                                    出價：<em class="red">*</em>
                                </label>

                                <div class="controls">
                                    <g:textField class="span4 price" name="price.${i}" id="price.${i}" required="true"
                                                 length="48" value="${creativePair.creative.price}"/>
                                    <span class="add-on">
                                        <a id="price_info" class="btn btn-mini btn-info price_info">
                                            <i class="icon-info-sign icon-white"></i>
                                        </a>
                                    </span>
                                    <g:if test="${creativePair.errorMesseage.contains("price")}"><div
                                            class="errorMesseage">請輸入正確的價格</div></g:if>
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </g:each>
                <div id="next_creative"></div>

                <div class="form-actions">
                    <a id="new_creative" class="btn btn-small btn-info pull-right" href="#new_creative"><i
                            class="icon-plus icon-white"></i>新增廣告內容</a>
                </div>

                <div class="form-actions">
                    <input type="submit" class="btn btn-primary" value="儲存並完成">
                    <input type="submit" class="btn" value="取消"/>
                </div>
            </g:uploadForm>
        </div>

        <div class="well span4">
            <table class="table-hover table-striped">
                <thead><tr><th>廣告活動預覽</th></tr></thead>
                <tbody>
                <tr><td>活動名稱</td><td>${campaign.name}</td></tr>
                <tr><td>開始時間</td><td>${campaign.startDatetime.format("yyyy-MM-dd")}</td></tr>
                <tr><td>結束時間</td><td>${campaign.endDatetime.format("yyyy-MM-dd")}</td></tr>
                <tr><td>每日預算</td><td>${campaign.dailyBudget}</td></tr>
                <tr><td>總廣告數</td><td>${campaign.creatives.size()}</td></tr>
                </tbody>
            </table>
            
            <g:each in="${campaign.creatives}" var="creative" status="i">
                <br/>
                <table class="table-hover table-striped creative-table">
                    <thead><tr><th>廣告${i}</th></tr></thead>
                    <tbody>
                    <tr><td>廣告名稱</td><td>${creative.name}</td></tr>
                    <tr><td>廣告連結</td><td>${creative.link}</td></tr>
                    <tr><td>顯示文字</td><td>${creative.displayText}</td></tr>
                    <tr><td>廣告圖片</td><td>${creative.imageUrl}</td></tr>
                    <tr><td>出價</td><td>${creative.price}</td></tr>
                    </tbody>
                </table>
            </g:each>
        </div>
    </div>
</div>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="${resource(dir: "js", file: "bootstrap.min.js")}"></script>
<script src="${resource(dir: "js", file: "jquery.validate.js")}"></script>
<script>
    var adCount = ${creativeList.size()};

    $(function () {
        addTextInfo();
        addValidate();
    });

    $("#creative_form").validate({
        rules: {

        },
        messages: {

        }
    });

    $('#new_creative').click(function () {
        $('#next_creative').append($('#creative_field_0').html());

        $('legend')[adCount].innerHTML = "廣告內容" + (adCount + 1);

        $('select')[adCount].id = "ad_type." + adCount;
        $('select')[adCount].name = "ad_type." + adCount;

        $('input.ad_name')[adCount].id = "ad_name." + adCount;
        $('input.ad_name')[adCount].name = "ad_name." + adCount;
        ;

        $('input.ad_link')[adCount].id = "ad_link." + adCount;
        $('input.ad_link')[adCount].name = "ad_link." + adCount;

        $('input.display_text')[adCount].id = "display_text." + adCount;
        $('input.display_text')[adCount].name = "display_text." + adCount;

        $('input.uploader')[adCount].id = "upload_file." + adCount;
        $('input.uploader')[adCount].name = "upload_file." + adCount;

        $('input.price')[adCount].id = "price." + adCount;
        $('input.price')[adCount].name = "price." + adCount;

        adCount++;
        addValidate();
        addTextInfo();
    })

    function addTextInfo() {
        $('.ad_type').popover({
            'trigger': 'hover',
            'content': '廣告類別，可選擇行動裝置廣告(如AdMob與Airpush所提供之廣告類型) 或 影音廣告(建立符合VAST 3.0規格之廣告內容)。'
        });
        $('.ad_name_info').popover({
            'trigger': 'hover',
            'content': '僅供識別之用，廣告受眾將不會看到此名稱。同一廣告活動中各廣告內容名稱必須是唯一的，此名稱最多允許輸入30個字元。'
        });
        $('.ad_link_info').popover({
            'trigger': 'hover',
            'content': '廣告受眾點擊廣告後將被導去的網路位址；請務必確認這是您希望受眾瀏覽的產品頁面。'
        });
        $('.display_text_info').popover({
            'trigger': 'hover',
            'content': '當廣告圖片無法顯示，或需要顯示代表廣告內容的文字時，將用以顯示的文字。'
        });
        $('.upload_file_info').popover({
            'trigger': 'hover',
            'content': '實際用以顯示的廣告圖片；最大檔案尺寸為500kb；並僅允許jpg、jpeg與png等圖片格式。'
        });
        $('.price_info').popover({
            'trigger': 'hover',
            'content': '廣告的單價。'
        });
    }

    function addValidate() {
        $('.ad_name').each(function () {
            $(this).rules("add", {
                required: true,
                maxlength: 30,
                messages: {
                    required: "此欄位為必填欄位。",
                    maxlength: "廣告內容名稱不能超過30個字元。"
                }
            });
        })

        $('.ad_link').each(function () {
            $(this).rules("add", {
                required: true,
                messages: {
                    required: "此欄位為必填欄位。"
                }
            });
        })

        $('.display_text').each(function () {
            $(this).rules("add", {
                required: true,
                maxlength: 48,
                messages: {
                    required: "此欄位為必填欄位。",
                    maxlength: "廣告內容名稱不能超過48個字元。"
                }
            });
        })

        $('.uploader').each(function () {
            $(this).rules("add", {
                required: true,
                messages: {
                    required: "必須上傳廣告圖片以建立廣告內容。"
                }
            });
        })

        $('.uploader').each(function () {
            $(this).rules("add", {
                required: true,
                messages: {
                    required: "此欄位為必填欄位。"
                }
            });
        })
    }
</script>
</body>
</html>
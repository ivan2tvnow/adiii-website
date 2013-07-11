package adiii

import grails.converters.JSON
import groovy.json.JsonSlurper
import org.codehaus.groovy.grails.web.context.ServletContextHolder

class ApiController {
    /*
     *  URL: /api/search?adId=${campaignId}&apiKey=${user.apiKey}
     *  當廣告主已知廣告ID時, 可透過此API呼叫直接取得廣告活動內容.
     */

    def search() {
        def apiKey = params.apiKey
        def adId = params.adId

        SessionData sessionData = new SessionData()
        sessionData.deviceId = 'ABC'
        sessionData.campaign = Campaign.get(adId)
        sessionData.accessKey = keyGenerator((('A'..'Z') + ('0'..'9')).join(), 11)
        sessionData.creative = getRandomCreative(sessionData.campaign, 'videoAd')
        def vastClosure = makeVastClosure(sessionData)

        render(contentType: "application/xml", vastClosure)
    }

    /*
     *  URL: /api/getAd?apiKey=${user.apiKey}
     *  Adiii SDK取得廣告的主要API, 本方法應取得開發者驗證資訊, 使用者資訊等, 以利本平台演算法推播最適當的廣告.
     */

    def getAd() {
        def apiKey = params.apiKey
        if (!apiKey)
        {
            def errorMap = getErrorMap(104)
            render errorMap as JSON
            return
        }

        if (params.apiKey instanceof String[])
        {
            def errorMap = getErrorMap(105)
            render errorMap as JSON
            return
        }

        if (!User.findByApikey(apiKey))
        {
            def errorMap = getErrorMap(106)
            render errorMap as JSON
            return
        }

        SessionData sessionData = new SessionData()
        sessionData.deviceId = 'ABC'
        sessionData.campaign = getCampaign()
        sessionData.accessKey = keyGenerator((('A'..'Z') + ('0'..'9')).join(), 11)
        sessionData.creative = getRandomCreative(sessionData.campaign, 'videoAd')

        if (sessionData.save(flush: true))
        {
            def vastClosure = makeVastClosure(sessionData)
            render(contentType: "application/xml", vastClosure)
        }
        else
        {
            render sessionData.errors
        }

        return
    }

    /*
     *   URL: /api/impression?sessionKey=${user.apiKey}&id=${creative.id}
     *   增加指定creative裡面的impression值
     */

    def impression()
    {
        //TODO: needs further improvement of the database accessing performance.
        SessionData sessionData = SessionData.findByAccessKey(params.data)
        if (sessionData && !sessionData.impression) {
            sessionData.impression = true
            def creative = sessionData.creative

            //add impression info
            withClientInfo { info ->
                def impressions = new Impression(info)
                creative.addToImpressions(impressions)
                creative.save(failOnError: true)
            }

            def dailyState = DailyStat.find {
                campaign == sessionData.campaign && statDate.format("yyyy/MM/dd") == new Date().format("yyyy/MM/dd")
            } ?: new DailyStat(campaign: sessionData.campaign)

            dailyState.impression ++
            dailyState.save()

            render 'success'
        }

        render 'session not found'
    }

    /*
     *   URL: /api/impression?click=${user.apiKey}&id=${creative.id}
     *   增加指定creative裡面的click值
     */

    def click() {
        SessionData sessionData = SessionData.findByAccessKey(params.data)
        if (sessionData) {
            if (sessionData.impression && !sessionData.click)
            {
                def creative = sessionData.creative

                //add click info
                withClientInfo { info ->
                    def clicks = new Click(info)
                    creative.addToClicks(clicks)
                    creative.save(failOnError: true)
                }

                def dailyState = DailyStat.find {
                    campaign == sessionData.campaign && statDate.format("yyyy/MM/dd") == new Date().format("yyyy/MM/dd")
                } ?: new DailyStat(campaign: sessionData.campaign)

                dailyState.click ++
                dailyState.save()
            }
            sessionData.campaign = null
            sessionData.creative = null
            sessionData.delete()

            render 'success'
        }
        else
        {
            render 'session not found'
        }
    }

    /*
     *  URL: /api/campaign (using POST)
     *  用以新增, 修改, 刪除廣告活動的API.
     */

    def campaigns() {
        try {
            def slurper = new JsonSlurper()
            def result = slurper.parseText(request.inputStream.text)

            Campaign campaign = new Campaign()
            campaign.name = result.campaignName
            campaign.startDatetime = Date.parse("yyyy/MM/dd HH:mm", result.startDatetime)
            campaign.hasEndDatetime = false
            campaign.endDatetime = campaign.startDatetime + 7
            campaign.dailyBudget = 50

            User user = User.findByEmail('test.user@gmail.com')
            println user
            user.addToCampaigns(campaign)
            if (!user.save(flush: true)) {
                user.errors.each {
                    println it
                }
            }

            String storagePath = ""
            def servletContext = ServletContextHolder.servletContext
            storagePath = servletContext.getRealPath('assets')

            def storageDir = new File(storagePath)
            if (!storageDir.exists()) {
                print "Creating directory ${storagePath}: "
                if (storageDir.mkdirs()) {
                    println "SUCCESS"
                } else {
                    println "FAILED"
                }
            }

            println campaign
            def file = new File(storageDir, "${campaign.id}.png")
            file.setBytes(result.adImage.decodeBase64())

            VideoAdCreative creative = new VideoAdCreative()
            creative.name = "creative_${result.campaignName}"
            creative.link = result.adLink
            creative.displayText = result.displayText
            creative.imageUrl = file.absolutePath
            creative.price = 10.0

            campaign.addToCreatives(creative)
            if (!campaign.validate() && !creative.validate()) {
                def errorList = []
                campaign.errors.allErrors.each {
                    errorList.add(it)
                }
                creative.errors.allErrors.each {
                    errorList.add(it)
                }

                render(contentType: "text/json") {
                    [error: errorList]
                }
            }
            campaign.save()

            def map = [:]
            map.adId = campaign.id
            render map as JSON
        }
        catch (any) {
            //log.error(any.toString(), any)
            //render any as JSON
            render "an error happened!!"
        }
    }

    /*
     *  (not an action method)
     *   抓取所有campain
     */

    def getCampaignNames() {
        List result = []
        def campaigns = Campaign.getAll()
        campaigns.each { campaign ->
            result.add(campaign.name)
        }

        render(contentType: "text/json") {
            [name: result]
        }
    }

    /*
         *   (not an action method)
         *   抓取client端數值：IP、時間、裝置ID
         */

    private void withClientInfo(Closure c) {
        def returnValue = [ipAddress: request.getRemoteAddr(), createdDatetime: new Date(), deviceId: params.data]
        c.call returnValue
    }

    /*
     *   (not an action method)
     *   取得要投放的廣告活動, 目前只有兩個方式:1)亂數挑選, 2)給予預設廣告活動.
     *
     */

    private getCampaign() {
        def query = Campaign.where {
            creatives.size() > 0
        }
        def campaigns = query.list()

        if (campaigns?.size()) {
            def randomIndex = new Random().nextInt(campaigns.size())
            return campaigns.get(randomIndex)
        } else {
            return getDefaultCampaign()
        }
    }

    /*
     *   (not an action method)
     *   給予預設廣告活動內容.
     */

    private getDefaultCampaign() {
        def campaign = new Campaign(name: 'Adiii Advertising Platform',
                startDatetime: new Date(),
                hasEndDatetime: false,
                endDatetime: new Date() + 365,
                dailyBudget: 50,
                campaignType: 'video_ad')
        def creative = new Creative(name: 'Adiii Advertising Platform',
                link: 'http://adiii.org/',
                displayText: 'Adiii廣告平台',
                imageUrl: 'http://adiii.org/ad_banner_300_60.png')
        campaign.addToCreatives(creative)

        return campaign
    }

    /*
     *   (not an action method)
     *   Error code與error message的對映.
     */

    private getErrorMap(Integer errorCode) {
        def map = [:]
        switch (errorCode) {
            case 104:
                map.message = "Bad authentication data."
                map.type = "AuthException"
                break
            case 105:
                map.message = "Too many authentication data."
                map.type = "AuthException"
                break
            case 106:
                map.message = "Api Key not found."
                map.type = "AuthException"
                break
        }

        map.code = errorCode
        return ['error': map]
    }

    /*
     *   (not an action method)
     *   根據廣告活動產生VAST格式內容closure.
     */

    private makeVastClosure(SessionData sessionData) {
        def adId = "adiii_${sessionData.campaign.id}"

        def host = "${request.scheme}://${request.serverName}:${request.serverPort}${request.contextPath}"
        def impressionUrl = "${host}/api/impression?data=${sessionData.accessKey}"
        def clickUrl = "${host}/api/click?data=${sessionData.accessKey}"

        def vastClosure = {
            mkp.xmlDeclaration()
            VAST(version: "3.0", 'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance", 'xsi:noNamespaceSchemaLocation': "vast.xsd") {
                Ad(id: adId) {
                    InLine() {
                        AdSystem(version: "1.0")
                        AdTitle("${sessionData.campaign.name}")
                        Description()
                        Advertiser()
                        Error()
                        Impression(id: "adiii_${sessionData.campaign.id}",
                                impressionUrl)
                        Creatives() {
                            Creative(id: "adiii_cr_0",
                                    sequence: "1",
                                    adId: adId) {
                                Linear() {
                                    Duration("00:00:52")
                                    MediaFiles() {
                                        MediaFile(id: "1", delivery: "streaming", type: "video/mp4", width: "854", height: "480",
                                                "rtmp://rmcdn.f.2mdn.net/ondemand/MotifFiles/html/1379578/parisian_love_126566284014011.flv")
                                    }
                                    VideoClicks() {
                                        ClickTracking(clickUrl)
                                    }
                                }
                            }
                            Creative(id: "adiii_cr_${sessionData.creative.id}",
                                    sequence: "1",
                                    adId: adId) {
                                CompanionAds() {
                                    Companion(id: "1", width: "550", height: "480") {
                                        StaticResource(creativeType: "image/png",
                                                "${host}/assets/${sessionData.creative.id}.png")
                                        CompanionClickThrough(sessionData.creative.link)
                                        AltText()
                                        AdParameters()
                                    }
                                }
                            }
                        }
                        Extensions() {}
                    }
                }
            }
        }

        return vastClosure
    }

    /*
     *   (not an action method)
     *   產生一串亂數的字碼
     */
    private keyGenerator = { String alphabet, int n ->
        new Random().with {
            (1..n).collect { alphabet[nextInt(alphabet.length())] }.join()
        }
    }

    private getRandomCreative(Campaign campaign, type) {
        def result = []
        if (type == 'videoAd') {
            campaign.creatives.each { creative ->
                if (creative instanceof adiii.VideoAdCreative) {
                    result.add(creative)
                }
            }
        } else if (type == 'mobileAd') {
            campaign.creatives.each { creative ->
                if (creative instanceof adiii.MobileAdCreative) {
                    result.add(creative)
                }
            }
        }

        if (result?.size()) {
            def randomIndex = new Random().nextInt(result.size())
            return result.get(randomIndex)
        } else {
            return new Creative()
        }
    }
}

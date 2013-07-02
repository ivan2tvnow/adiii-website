package adiii

import grails.converters.JSON
import groovy.json.JsonOutput
import groovy.json.JsonSlurper
import groovy.xml.MarkupBuilder
import org.codehaus.groovy.grails.web.context.ServletContextHolder

class ApiController
{
    /*
     *  URL: /api/search?adId=${campaignId}&apiKey=${user.apiKey}
     *  當廣告主已知廣告ID時, 可透過此API呼叫直接取得廣告活動內容.
     */
    def search()
    {
        def apiKey = params.apiKey
        def adId = params.adId

        def campaign = Campaign.get(adId)
        def vastClosure = makeVastClosure(campaign)

        render(contentType: "application/xml", vastClosure)
    }

    /*
     *  URL: /api/getAd?apiKey=${user.apiKey}
     *  Adiii SDK取得廣告的主要API, 本方法應取得開發者驗證資訊, 使用者資訊等, 以利本平台演算法推播最適當的廣告.
     */
    def getAd()
    {
        def apiKey = params.apiKey
        if(!apiKey)
        {
            def errorMap = getErrorMap(104)
            render errorMap as JSON
            return
        }

        if(params.apiKey instanceof String[])
        {
            def errorMap = getErrorMap(105)
            render errorMap as JSON
            return
        }

        def campaign = getCampaign(apiKey)
        def vastClosure = makeVastClosure(campaign)

        render(contentType: "application/xml", vastClosure)
    }

    /*
     *  URL: /api/campaign (using POST)
     *  用以新增, 修改, 刪除廣告活動的API.
     */
    def campaigns()
    {
        try
        {
            def slurper = new JsonSlurper()
            def result = slurper.parseText(request.inputStream.text)

            Campaign campaign = new Campaign()
            campaign.name = result.campaignName
            campaign.startDatetime = Date.parse("yyyy/MM/dd HH:mm", result.startDatetime)
            campaign.hasEndDatetime = false
            campaign.endDatetime = campaign.startDatetime + 7
            campaign.dailyBudget = 50
            campaign.campaignType = 'video_ad'

            User user = User.findByEmail('test.user@gmail.com')
            println user
            user.addToCampaigns(campaign)
            if(!user.save(flush: true))
            {
                user.errors.each {
                    println it
                }
            }

            String storagePath = ""
            def servletContext = ServletContextHolder.servletContext
            storagePath = servletContext.getRealPath('assets')

            def storageDir = new File(storagePath)
            if(!storageDir.exists())
            {
                print "Creating directory ${storagePath}: "
                if(storageDir.mkdirs())
                {
                    println "SUCCESS"
                }
                else
                {
                    println "FAILED"
                }
            }

            println campaign
            def file = new File(storageDir, "${campaign.id}.png")
            file.setBytes(result.adImage.decodeBase64())

            Creative creative = new Creative()
            creative.name = "creative_${result.campaignName}"
            creative.link = result.adLink
            creative.displayText = result.displayText
            creative.imageUrl = file.absolutePath

            campaign.addToCreatives(creative)
            campaign.save()

            def map = [:]
            map.adId = campaign.id
            render map as JSON
        }
        catch(any)
        {
            log.error(any.toString(), any)
            render any as JSON
        }
    }

    /*
     *   (not an action method)
     *   取得要投放的廣告活動, 目前只有兩個方式:1)亂數挑選, 2)給予預設廣告活動.
     *
     */
    def getCampaign(String apiKey)
    {
        def query = Campaign.where {
            User.findByApikey(apiKey) && creatives.size() > 0
        }
        def campaigns = query.list()

        if(campaigns?.size())
        {
            def randomIndex = new Random().nextInt(campaigns.size())
            return campaigns.get(randomIndex)
        }
        else
        {
            return getDefaultCampaign()
        }
    }

    /*
     *   (not an action method)
     *   給予預設廣告活動內容.
     */
    def getDefaultCampaign()
    {
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
    def getErrorMap(Integer errorCode)
    {
        def map = [:]
        switch(errorCode)
        {
            case 104:
                map.message= "Bad authentication data."
                map.type= "AuthException"
                break
            case 105:
                map.message= "Too many authentication data."
                map.type= "AuthException"
                break
        }

        map.code= errorCode
        return ['error': map]
    }

    /*
     *   (not an action method)
     *   根據廣告活動產生VAST格式內容closure.
     */
    def makeVastClosure(Campaign campaign)
    {
        def adId = "adiii_${campaign.id}"

        def host = "${request.scheme}://${request.serverName}:${request.serverPort}${request.contextPath}"
        def impressionUrl = "${host}/imp?data=${campaign.id}%2Fotherdatafields?${host}/dot.gif"
        def clickUrl = "${host}/imp;v7;x;223626133;0-0;0;47414737;0/0;31349900/31367776/1;;~aopt=0/0/ff/0;~cs=l%3fhttp://s0.2mdn.net/dot.gif"

        def vastClosure = {
            mkp.xmlDeclaration()
            VAST(version:"3.0", 'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance", 'xsi:noNamespaceSchemaLocation': "vast.xsd") {
                Ad(id: adId){
                    InLine(){
                        AdSystem(version: "1.0")
                        AdTitle("${campaign.name}")
                        Description()
                        Advertiser()
                        Error()
                        Impression(id: "adiii_${campaign.id}",
                                   impressionUrl)
                        Creatives(){
                            Creative(id: "adiii_cr_0",
                                    sequence: "1",
                                    adId: adId){
                                Linear(){
                                    Duration("00:00:52")
                                    MediaFiles(){
                                        MediaFile(id: "1", delivery: "streaming", type: "video/mp4", width: "854", height: "480",
                                                "rtmp://rmcdn.f.2mdn.net/ondemand/MotifFiles/html/1379578/parisian_love_126566284014011.flv")
                                    }
                                }
                            }
                            for(creative in campaign.creatives)
                            {
                                Creative(id: "adiii_cr_${creative.id}",
                                        sequence: "1",
                                        adId: adId){
                                    CompanionAds(){
                                        Companion(id: "1", width: "550", height: "480"){
                                            StaticResource(creativeType: "image/png",
                                                           "${host}/assets/${creative.id}.png")
                                            CompanionClickThrough(creative.link)
                                            AltText()
                                            AdParameters()
                                        }
                                    }
                                }
                            }
                        }
                        Extensions(){}
                    }
                }
            }
        }

        return vastClosure
    }
}

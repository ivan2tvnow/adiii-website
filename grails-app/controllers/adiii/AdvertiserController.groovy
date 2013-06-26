package adiii

import grails.plugins.springsecurity.Secured

class AdvertiserController
{
    static allowedMethods = [index: ['GET', 'POST']]
    def springSecurityService

    /*
     *  URL: /advertiser/index
     *  廣告主首頁, 即顯示所有廣告主可進行操作與顯示所有廣告活動的頁面.
     */
    @Secured(['ROLE_ADVERTISER'])
    def index()
    {
        Map modelMap = [:]

        User advertiser = springSecurityService.getCurrentUser()

        modelMap.campaignCount = advertiser.campaigns.size()
        modelMap.campaigns = advertiser.campaigns.toList()

        render(view: "index", model: modelMap)
    }

    /*
     *  URL: /advertiser/campaign/${campaign.id}, ex: /advertiser/campaign/5566
     *  廣告活動(campaign)資訊頁面, 顯示廣告活動的詳細資訊, 主要顯示其所包含的所有廣告內容(creatives)
     */
    @Secured(['ROLE_ADVERTISER'])
    def campaign()
    {
        Campaign campaign = Campaign.get(params.id)
        if(campaign != null)
        {
            if(campaign.creatives.size() > 0)
            {
                Map modelMap = [:]
                modelMap.campaignName = campaign.name
                modelMap.creatives = campaign.creatives
                modelMap.creativeCount = campaign.creatives?.size()
                render(view: "campaign", model: modelMap)
            }
            else
            {
                redirect(controller: "advertiser", action: "addvidadcreative", id: campaign.id)
            }
        }
        else
        {
            render "<h1>No such resource!</h1>"
        }
    }

    /*
     *  URL: /advertiser/addcampaign
     *  廣告主用以新增廣告活動(campaign)的頁面
     */
    @Secured(['ROLE_ADVERTISER'])
    def addcampaign()
    {
        Map modelMap = [:]
        // TODO: the work of counting the total number of owned campaigns must be cached.
        modelMap.campaignCount = Campaign.count()

        Calendar tmpCal = Calendar.getInstance(TimeZone.getTimeZone('GMT+8:00'))
        modelMap.startDate = tmpCal.format("yyyy/MM/dd")

        tmpCal.add(Calendar.DATE, 7)
        modelMap.endDate = tmpCal.format("yyyy/MM/dd")

        List hourList = (0..23).collect({
            String.format("%02d", it)
        })
        modelMap.hourList = hourList

        String selectHour = tmpCal.format("HH")
        if(tmpCal.get(Calendar.MINUTE) >= 30)
        {
            tmpCal.add(Calendar.HOUR_OF_DAY, 1)
            selectHour = tmpCal.format("HH")
        }
        modelMap.selectHour = selectHour

        render(view: "addcampaign", model: modelMap)
    }

    /*
     *  URL: /advertiser/addvidadcreative/${campaign.id}
     *  廣告主用以為廣告活動(campaign)新增影片廣告內容(creative)的頁面
     *  注意URL的第三個segment為目前要為其建立內容的campaign ID
     */
    @Secured(['ROLE_ADVERTISER'])
    def addvidadcreative()
    {
        Integer count = Campaign.count()

        Integer campId = params.int('id')
        Campaign campaign = Campaign.get(campId)

        render(view: "addvidadcreative", model: [campaignCount: count, campaignId: campId])
    }

    /*
     *  URL: /advertiser/addmobadcreative/${campaign.id}
     *  廣告主用以為廣告活動(campaign)新增行動廣告內容(creative)的頁面
     *  注意URL的第三個segment為目前要為其建立內容的campaign ID
     */
    @Secured(['ROLE_ADVERTISER'])
    def addmobadcampaign(){
        render(view: "addmobadcampaign")
    }

    /*
     *  URL: /advertiser/reports
     *  顯示廣告投放狀況的頁面
     */
    @Secured(['ROLE_ADVERTISER'])
    def reports(){
        render(view: "reports")
    }

    /*
     *  URL: /advertiser/account
     *  顯示廣告主帳戶狀況的頁面, 此頁面用以顯示與操作與金錢額度相關的資訊與操作.
     */
    @Secured(['ROLE_ADVERTISER'])
    def account(){
        render(view: "account")
    }
}

package adiii

import grails.plugins.springsecurity.Secured

class AdvertiserController
{
    static allowedMethods = [index: ['GET', 'POST']]
    def springSecurityService
    def NUM_PER_PAGE = 50
    def SHOW_PAGE_LENGTH = 5

    /*
     *  URL: /advertiser/index
     *  廣告主首頁, 即顯示所有廣告主可進行操作與顯示所有廣告活動的頁面.
     */
    @Secured(['ROLE_ADVERTISER'])
    def index()
    {
        User advertiser = springSecurityService.getCurrentUser()
        int currentPage = 1
        if (params.page)
        {
            currentPage = params.page.toInteger()
        }

        int offset = (currentPage - 1) * NUM_PER_PAGE
        int campaignCount = advertiser.campaigns.size()
        int totalPage = Math.ceil(campaignCount / NUM_PER_PAGE)

        Map modelMap = [:]
        modelMap.currentPage = currentPage
        modelMap.totalPage = totalPage
        modelMap.campaignCount = campaignCount
        modelMap.campaigns = Campaign.list(max: NUM_PER_PAGE, offset: offset, sort: "id", order: "desc", fetch: [user: advertiser])
        modelMap.pageList = getPageList(currentPage, totalPage)

        modelMap.statistics = [:]
        for (campaign in modelMap.campaigns)
        {
            int total_impression = 0
            int total_click = 0
            for (creative in campaign.creatives)
            {
                total_impression += creative.impressions.size()
                total_click += creative.clicks.size()
            }
            modelMap.statistics.put(campaign.id, [impression: total_impression, click: total_click])
        }

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
                modelMap.campaignId = campaign.id
                modelMap.creatives = campaign.creatives
                modelMap.creativeCount = campaign.creatives?.size()
                render(view: "campaign", model: modelMap)
            }
            else
            {
                redirect(controller: "advertiser", action: "addcreative", id: campaign.id)
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
        Campaign campaign = new Campaign(dailyBudget: 50)
        modelMap.campaign = campaign

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
        modelMap.errorMesseage = []

        render(view: "addcampaign", model: modelMap)
    }

    @Secured(['ROLE_ADVERTISER'])
    def addcreative()
    {
        Map modelMap = [:]
        modelMap.creativeList = []
        modelMap.campaignCount = Campaign.count()
        modelMap.campaignId = params.int('id')

        def miniMap = [:]
        miniMap.errorMesseage = []
        miniMap.creative = new Creative(link: 'http://www.example.com', price: 1.0)
        modelMap.creativeList.add(miniMap)

        render(view: "addcreative", model: modelMap)
    }

    /*
     *  URL: /advertiser/addvidadcreative/${campaign.id}
     *  廣告主用以為廣告活動(campaign)新增影片廣告內容(creative)的頁面
     *  注意URL的第三個segment為目前要為其建立內容的campaign ID
     */
    @Secured(['ROLE_ADVERTISER'])
    def addvidadcreative()
    {
        Map modelMap = [:]
        modelMap.errorMesseage = []
        modelMap.campaignCount = Campaign.count()
        modelMap.campaignId = params.int('id')
        modelMap.creative = new VideoAdCreative(link: 'http://www.example.com', price: 1.0)

        render(view: "addvidadcreative", model: modelMap)
    }

    /*
     *  URL: /advertiser/addvidadcreative/${campaign.id}
     *  廣告主用以為廣告活動(campaign)新增影片廣告內容(creative)的頁面
     *  注意URL的第三個segment為目前要為其建立內容的campaign ID
     */
    @Secured(['ROLE_ADVERTISER'])
    def addmobileadcreative()
    {
        Map modelMap = [:]
        modelMap.errorMesseage = []
        modelMap.campaignCount = Campaign.count()
        modelMap.campaignId = params.int('id')
        modelMap.creative = new MobileAdCreative(link: 'http://www.example.com', price: 1.0)

        render(view: "addmobileadcreative", model: modelMap)
    }

    /*
     *  URL: /advertiser/addmobadcreative/${campaign.id}
     *  廣告主用以為廣告活動(campaign)新增行動廣告內容(creative)的頁面
     *  注意URL的第三個segment為目前要為其建立內容的campaign ID
     */
    @Secured(['ROLE_ADVERTISER'])
    def addmobadcampaign() {
        render(view: "addmobadcampaign")
    }

    /*
     *  URL: /advertiser/reports
     *  顯示廣告投放狀況的頁面
     */
    @Secured(['ROLE_ADVERTISER'])
    def reports()
    {
        Map modelMap = [:]
        User advertiser = springSecurityService.getCurrentUser()
        modelMap.campaignList = advertiser.campaigns.toList()
        modelMap.fistContentList = ['impression', 'click', 'CTR']
        modelMap.secondContentList = ['impression', 'click', 'CTR']
        def today = new Date()
        modelMap.startDate = (today - 7).format("yyyy-MM-dd")
        modelMap.endDate = today.format("yyyy-MM-dd")

        render(view: "reports", model: modelMap)
    }

    /*
     *  URL: /advertiser/account
     *  顯示廣告主帳戶狀況的頁面, 此頁面用以顯示與操作與金錢額度相關的資訊與操作.
     */
    @Secured(['ROLE_ADVERTISER'])
    def account() {
        render(view: "account")
    }

    /*
     *  (not an action method)
     *  依據需求計算出該顯示出的分頁.
     */
    private getPageList(current, total)
    {
        def range = (SHOW_PAGE_LENGTH - 1) / 2

        if (total < SHOW_PAGE_LENGTH)
        {
            return (1..total).toList()
        }
        else if (current <= (range + 1))
        {
            return (1..SHOW_PAGE_LENGTH).toList()
        }
        else if (current >= (total - range))
        {
            return ((total - SHOW_PAGE_LENGTH)..total).toList()
        }
        else
        {
            return ((current - range)..(current + range)).toList()
        }
    }
}

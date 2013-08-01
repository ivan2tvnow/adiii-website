package adiii

class AjaxApiController {

    def getReports()
    {
        Date today = Date.parse("yyyy-MM-dd", "${params.end}")
        Date lastDay = Date.parse("yyyy-MM-dd", "${params.start}")
        def dateList = []
        def impressionList = []
        def clickList = []
        def ctrList = []

        def dailyStates
        if (params.target == "all")
        {
            dailyStates = DailyStat.getAll()
        }
        else
        {
            def target_camp = Campaign.get(params.target)
            dailyStates = DailyStat.findAllByCampaign(target_camp)
        }

        (lastDay..today).each { d->
            dateList.add(d.format("yyyy/MM/dd"))

            int impression = 0
            int click = 0
            int ctr = 0

            for (dailyState in dailyStates)
            {
                if (dailyState.statDate == d.format("yyyy/MM/dd"))
                {
                    impression += dailyState.impression
                    click += dailyState.click
                }

                if (impression > 0)
                {
                    ctr = (click / impression) * 100
                }
                else
                {
                    ctr = 0
                }

            }

            impressionList.add(impression)
            clickList.add(click)
            ctrList.add(ctr)
        }

        def impressionMap = [name: "投放次數", data: impressionList]
        def clickMap = [name: "點擊次數", data: clickList]
        def ctrMap = [name: "CTR", data: ctrList]

        render(contentType: "text/json") {
            date = dateList
            output = array {
                if (params.first == 'impression' || params.second == 'impression') {
                    pair(impressionMap)
                }
                if (params.first == 'click' || params.second == 'click') {
                    pair(clickMap)
                }
                if (params.first == 'CTR' || params.second == 'CTR') {
                    pair(ctrMap)
                }
            }
        }
    }

    def getCampDateRange() {
        Campaign campaign = Campaign.get(params.id)

        render(contentType: "text/json") {
            startDate = campaign.startDatetime.format("yyyy-MM-dd")
            endDate = campaign.endDatetime.format("yyyy-MM-dd")
        }
    }
}

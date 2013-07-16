package adiii

class AjaxApiController {

    def index() {}

    def getReports()
    {
        Date today = new Date()
        def lastDay = today - 14
        def dateList = []
        def impressionList = []
        def clickList = []

        def dailyStates
        if (params.target == "all")
        {
            dailyStates = DailyStat.getAll()
        }
        else
        {
            def target_camp = Campaign.findByName(params.target)
            dailyStates = DailyStat.findAllByCampaign(target_camp)
        }

        (lastDay..today).each { d->
            dateList.add(d.format("yyyy/MM/dd"))

            int impression = 0
            int click = 0

            for (dailyState in dailyStates) {
                if (dailyState.statDate == d.format("yyyy/MM/dd")) {
                    impression += dailyState.impression
                    click += dailyState.click
                }
            }

            impressionList.add(impression)
            clickList.add(click)
        }

        render(contentType: "text/json") {
            [date: dateList, impression: impressionList, click: clickList]
        }
    }
}

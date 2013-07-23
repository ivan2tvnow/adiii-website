package adiii

class DailyStatJob {

    static triggers = {
        simple repeatInterval: 60000 // execute job once in 5 seconds
    }

    def execute() {
        def impressions = Impression.getAll()
        def clicks = Click.getAll()
        Map statMap = [:]

        for (impression in impressions)
        {
            def parentCampaign = impression.campaign

            if (impression.createdDatetime.format("yyyy/MM/dd") == new Date().format("yyyy/MM/dd"))
            {
                if (!statMap.get(parentCampaign.id))
                {
                    def count = [1, 0]
                    statMap.put(parentCampaign.id, count)
                }
                else
                {
                    def count = statMap[parentCampaign.id]
                    count[0] ++
                    statMap[parentCampaign.id] = count
                }
            }
        }

        for (click in clicks)
        {
            def parentCampaign = click.creative.campaign

            if (click.createdDatetime.format("yyyy/MM/dd") == new Date().format("yyyy/MM/dd"))
            {
                if (!statMap.get(parentCampaign.id))
                {
                    def count = [0, 1]
                    statMap.put(parentCampaign.id, count)
                }
                else
                {
                    def count = statMap[parentCampaign.id]
                    count[1] ++
                    statMap[parentCampaign.id] = count
                }
            }
        }

        statMap.each { stat->
            def parentCampagn = Campaign.get(stat.key)

            def dailyStat = DailyStat.find {
                campaign == parentCampagn && statDate == new Date().format("yyyy/MM/dd")
            } ?: new DailyStat(campaign: parentCampagn)

            def count = stat.value
            dailyStat.impression = count[0]
            dailyStat.click = count[1]
            if (!dailyStat.save(flush: true))
            {
                println "State update failed!"
            }
        }

        //println "State updated!"
    }
}

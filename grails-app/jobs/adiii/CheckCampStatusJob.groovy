package adiii



class CheckCampStatusJob {
    static triggers = {
        cron name: 'cronTrigger', cronExpression: "0 0/15 * * * ?"
    }

    def execute() {
        Date today = new Date()
        def campaignList = Campaign.findByEndDatetimeLessThan(today)

        campaignList.each { campaign ->
            campaign.status = "END"
            campaign.save()
        }
    }
}

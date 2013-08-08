package adiii



class CheckCampStatusJob {
    static triggers = {
        cron name: 'cronTrigger', cronExpression: "0 0/15 * * * ?"
    }

    def execute() {
        Date today = new Date()
        def campaignList = Campaign.getAll()

        campaignList.each { campaign ->
            if (campaign.endDatetime < today && campaign.hasEndDatetime)
            {
                if (campaign.status != "END")
                {
                    campaign.status = "END"
                    campaign.save(flush: true, failOnError: true)
                }
            }
            else if (campaign.creatives.size() < 0) {
                campaign.status = "DRAFT"
                campaign.save(flush: true, failOnError: true)
            }
            else if (campaign.status == "END")
            {
                campaign.status = "READY"
                campaign.save(flush: true, failOnError: true)
            }
        }
    }
}

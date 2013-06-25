package adiii

class CampaignController
{
    /*
     *  URL: /advertiser/campaign/save
     *  實際進行廣告活動(campaign)儲存的action method;
     *  當儲存成功後, 將網頁導至/advertiser/creative/save/${campaign.id}, 以繼續進行廣告內容的建立.
     */
    def save()
    {
        Date startDate = Date.parse("yyyy/MM/dd HH:mm", "${params.start_date} ${params.start_hour}:${params.start_min}")
        Date endDate = Date.parse("yyyy/MM/dd HH:mm", "${params.end_date} ${params.end_hour ?: '23'}:${params.end_min ?: '59'}")
        Boolean checkEndDate = params?.check_end_date == 'on' ? true : false

        Campaign campaign = new Campaign(name: params.campaign_name,
                startDatetime: startDate,
                hasEndDatetime: checkEndDate,
                endDatetime: endDate,
                dailyBudget: params.int('daily_budget'),
                campaignType: params.campaign_type)

        User user = session?.user
        if(user == null)
        {
            user = User.findByEmail('test.user@gmail.com')
            if(user == null)
            {
                user = new User(email: "test.user@gmail.com",
                        password: "nmiisno1",
                        firstName: "Shao-Ming",
                        lastName: "Lin",
                        company: "III",
                        apiKey: "testuserapikey")
            }

            session.user = user
        }

        try{
            user.addToCampaigns(campaign)
        }
        catch(Exception e)
        {
            log.error(e.toString(), e)
        }

        if(user.save(flush: true))
        {
            redirect(controller: "advertiser", action: "addvidadcreative", id: campaign.id)
        }
        else
        {
            String error = ""
            user.errors.each {
                error += (it.toString() +'\n')
            }
            render error
        }
    }
}

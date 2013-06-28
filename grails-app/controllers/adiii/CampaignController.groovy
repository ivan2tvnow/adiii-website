package adiii

import grails.plugins.springsecurity.Secured

class CampaignController
{
    def springSecurityService
    /*
         *  URL: /advertiser/campaign/edit
         *  廣告修改的傳導頁;
         *  會讀取出指定ID的campaign並導到 /advertiser/editcampaign
         */
    @Secured(['ROLE_ADVERTISER'])
    def edit()
    {
        Map modelMap = [:]
        Integer campId = params.int('id')
        Campaign campaign = Campaign.get(campId)

        if(campaign != null)
        {
            modelMap.campaign = campaign
            modelMap.startDate = campaign.startDatetime.format("yyyy/MM/dd")
            modelMap.endDate = campaign.endDatetime.format("yyyy/MM/dd")

            List hourList = (0..23).collect({
                String.format("%02d", it)
            })
            modelMap.hourList = hourList
            flash.message = params.message

            render(view: "../advertiser/editcampaign", model: modelMap)
        }
        else
        {
            render "<h1>No such resource!</h1>"
        }
    }

    /*
         *  URL: /advertiser/campaign/save
         *  實際進行廣告活動(campaign)儲存的action method;
         *  當儲存成功後, 將網頁導至/advertiser/creative/save/${campaign.id}, 以繼續進行廣告內容的建立.
         */
    @Secured(['ROLE_ADVERTISER'])
    def save()
    {
        Date startDate = Date.parse("yyyy/MM/dd HH:mm", "${params.start_date} ${params.start_hour}:${params.start_min}")
        Date endDate = new Date()
        if (params?.check_end_date == 'on')
        {
            endDate = Date.parse("yyyy/MM/dd HH:mm", "${params.end_date} ${params.end_hour ?: '23'}:${params.end_min ?: '59'}")
        }
        Boolean checkEndDate = params?.check_end_date == 'on' ? true : false

        Campaign campaign = new Campaign(name: params.campaign_name,
                startDatetime: startDate,
                hasEndDatetime: checkEndDate,
                endDatetime: endDate,
                dailyBudget: params.int('daily_budget'),
                campaignType: params.campaign_type)

        User user = springSecurityService.getCurrentUser()
        if(user == null)
        {
            String message = "尚未登入"
            redirect(controller: "adiii", action: "index", params: [message: message])
            return
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
            if (campaign.campaignType == "video_ad")
            {
                redirect(controller: "advertiser", action: "addvidadcreative", id: campaign.id)
            }
            else if (campaign.campaignType == "mobile_ad")
            {
                redirect(controller: "advertiser", action: "addmobileadcreative", id: campaign.id)
            }

        }
        else
        {
            String message = ""
            user.errors.each {
                message += (it.toString() +'\n')
                println message
            }
            message = "資料出錯，請重新輸入"
            redirect(controller: "advertiser", action: "addcampaign", params: [message: message])
        }
    }

    /*
         *  URL: /advertiser/campaign/update
         *  實際進行廣告活動(campaign)更新的action method;
         *  當更新成功後, 將網頁導至/advertiser/index
         */
    @Secured(['ROLE_ADVERTISER'])
    def update()
    {
        Integer campId = params.int('id')
        Campaign campaign = Campaign.get(campId)
        Date startDate = Date.parse("yyyy/MM/dd HH:mm", "${params.start_date} ${params.start_hour}:${params.start_min}")
        Date endDate = new Date()
        if (params?.check_end_date == 'on')
        {
            endDate = Date.parse("yyyy/MM/dd HH:mm", "${params.end_date} ${params.end_hour ?: '23'}:${params.end_min ?: '59'}")
        }
        Boolean checkEndDate = params?.check_end_date == 'on' ? true : false

        campaign.setProperties(name: params.campaign_name,
                startDatetime: startDate,
                hasEndDatetime: checkEndDate,
                endDatetime: endDate,
                dailyBudget: params.int('daily_budget'),
                campaignType: params.campaign_type)

        String message = ""
        if(campaign.save(flush: true))
        {
            message = "修改成功"
            redirect(controller: "advertiser", action: "index", params: [message: message])
        }
        else
        {
            campaign.errors.each {
                message += (it.toString() +'\n')
                println message
            }
            message = "資料出錯，請重新輸入"
            redirect(action: "edit", id: campId, params: [message: message])
        }
    }

    @Secured(['ROLE_ADVERTISER'])
    def select() {
        def campaignIdList = [0]
        def campaignIds = params.list('campaign').get(0)
        campaignIds.each() { campaignId ->
            if (campaignId.key.isLong() && "on".equals(campaignId.value)) {
                campaignIdList.add(campaignId.key)
            }
        }

        if (params.submit == "刪除廣告")
        {
            redirect(action: "delete", params: [campaignIdList: campaignIdList])
        }
        else
        {
            redirect(controller: "advertiser", action: "index")
        }

    }

    @Secured(['ROLE_ADVERTISER'])
    def delete()
    {
        User user = springSecurityService.getCurrentUser()
        if(user == null)
        {
            String message = "尚未登入"
            redirect(controller: "adiii", action: "index", params: [message: message])
            return
        }

        for (campaignId in params.campaignIdList)
        {
            Campaign campaign = Campaign.get(campaignId)
            try{
                if (user.campaigns.remove(campaign))
                {
                    campaign.delete()
                }
            }
            catch(Exception e)
            {
                log.error(e.toString(), e)
            }

        }

        redirect(controller: "advertiser", action: "index")
    }
}

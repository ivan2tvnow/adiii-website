package adiii

import grails.plugins.springsecurity.Secured
import org.springframework.web.multipart.MultipartFile

class CreativeController
{
    def fileUploadService
    /*
         *  URL: /advertiser/vidoadcreative/edit
         *  影片廣告修改的傳導頁;
         *  會讀取出指定ID的creative並導到 /advertiser/editvidadcreative
         */
    @Secured(['ROLE_ADVERTISER'])
    def edit()
    {
        Map modelMap = [:]
        withCreative() { creative ->
            modelMap.creative = creative
            modelMap.errorMesseage = []
            goBackToEdit(modelMap)
        }
    }

    /*
     *  URL: /advertiser/creative/save/${campaign.id}
     *  實際進行廣告內容(creative)儲存的action method; 當儲存成功後, 將網頁導至/advertiser/index.
     */
    @Secured(['ROLE_ADVERTISER'])
    def save()
    {
        Integer campId = params.int('id')
        Campaign campaign = Campaign.get(campId)
        if (!campaign) {
            String message = "找不到相對應廣告"
            println message
            redirect(controller: "advertiser", action: "index", params: [message: message])
            return
        }

        withParamSetup() { creative ->
            validateCreative(creative, campId)
            campaign.addToCreatives(creative)
            if(campaign.save() && creative.save())
            {
                creative.imageUrl = uploadFile(creative.id)
                creative.save()

                redirect(controller: "advertiser", action: "campaign", id: campId)
            }
        }
    }

    /*
         *  URL: /advertiser/crrative/update
         *  實際進行廣告(creative)更新的action method;
         *  當更新成功後, 將網頁導至/advertiser/index
         */
    @Secured(['ROLE_ADVERTISER'])
    def update()
    {
        withCreative() { creative ->
            String tmp = validateImg()
            String result = tmp == 'tmp'?uploadFile(params.id):tmp
            creative.setProperties(name: params.ad_name,
                    link: params.ad_link,
                    displayText: params.display_text,
                    imageUrl: result,
                    price: params.price)
            validateCreative(creative, -1)
            if(creative.save()) {
                redirect(controller: "advertiser", action: "campaign", id: creative.campaign.id)
            }
        }
    }

    /*
         *  URL: /advertiser/creative/select
         *  對於多個creative進行動作
         *  此方法會根據傳過來的submit類別再導到對應的方法
         */
    @Secured(['ROLE_ADVERTISER'])
    def select()
    {
        def creativeIdList = [0]
        Integer campId = params.int('id')
        def creativeIds = params.list('creative').get(0)
        creativeIds.each() { creativeId ->
            if (creativeId.key.isLong() && "on".equals(creativeId.value)) {
                creativeIdList.add(creativeId.key)
            }
        }

        if (params.submit == "刪除內容")
        {
            redirect(action: "delete", params: [creativeIdList: creativeIdList, campId: campId])
        }
        else
        {
            redirect(controller: "advertiser", action: "campaign", id: campId)
        }
    }

    /*
         *  URL: /advertiser/creative/select
         *  刪除所選的creative
         *  摻除完成後會回到creative顯示頁
         */
    @Secured(['ROLE_ADVERTISER'])
    def delete()
    {
        Campaign campaign = Campaign.get(params.campId)
        if(!campaign)
        {
            redirect(controller: "advertiser", action: "campaign", params: [message: "找不到廣告活動", id: params.campId])
            return
        }

        for (creativeId in params.creativeIdList)
        {
            Creative creative = Creative.get(creativeId)
            try{
                if (campaign.creatives.remove(creative))
                {
                    creative.delete()
                }
            }
            catch(Exception e)
            {
                log.error(e.toString(), e)
            }
        }

        redirect(controller: "advertiser", action: "campaign", id: params.campId)
    }

    /*
         *  (not an action method)
         *  回傳所選id的creative
         *  若找不到則會用文字顯示
         */
    protected def withCreative(id="id", Closure c)
    {
        def creative = Creative.get(params[id])
        if (creative)
        {
            c.call creative
        }
        else
        {
            render "<h1>No such resource!</h1>"
        }
    }

    protected String validateImg() {
        return "tmp"
    }

    protected def validateCreative(creative, campId)
    {
        if (!creative.validate())
        {
            List errorMesseage = []
            if (creative.errors.hasFieldErrors("name"))
            {
                errorMesseage.add("name")
                creative.name = null
            }

            if (creative.errors.hasFieldErrors("link"))
            {
                errorMesseage.add("link")
                creative.link = null
            }

            if (creative.errors.hasFieldErrors("displayText"))
            {
                errorMesseage.add("displayText")
                creative.displayText = null
            }

            if (creative.errors.hasFieldErrors("imageUrl"))
            {
                errorMesseage.add("imageUrl")
                creative.imageUrl = null
            }

            if (creative.errors.hasFieldErrors("price"))
            {
                errorMesseage.add("price")
                creative.price = null
            }

            Map modelMap = [:]
            modelMap.creative = creative
            modelMap.errorMesseage = errorMesseage
            flash.message = "資料有誤"
            if (campId == -1)
            {
                goBackToEdit(modelMap)
            } else
            {
                modelMap.count = Campaign.count()
                modelMap.campaignId = campId
                goBackToAdd(modelMap)
            }
        }
    }

    /*
         *  (not an action method)
         *  以傳入的參數新增一個creative
         */
    protected def withParamSetup(id="id", Closure c)
    {
        def creative = new Creative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                price: params.price)

        c.call creative
    }

    /*
         *  (not an action method)
         *  將request裡面的檔案存到系統中
         */
    protected String uploadFile(fileName)
    {
        MultipartFile file = request.getFile('upload_file')
        String extension = file.contentType.split("/")[1]
        return fileUploadService.uploadFile(file, "${fileName}.${extension}")
    }

    /*
         *  (not an action method)
         *  導回新增creative的頁面
         */
    protected def goBackToAdd(modelMap)
    {
        render(view: "../advertiser/addcreative", model: modelMap)
    }

    /*
         *  (not an action method)
         *  導回編輯creative的頁面
         */
    protected def goBackToEdit(modelMap)
    {
        render(view: "../advertiser/editcreative", model: modelMap)
    }
}

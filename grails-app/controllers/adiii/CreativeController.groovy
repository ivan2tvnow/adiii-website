package adiii

import grails.plugins.springsecurity.Secured
import org.springframework.web.multipart.MultipartFile

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

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
        List trunBackCreativeList = []
        def adTypeList = params.list('ad_type').get(0)
        def adNameList = params.list('ad_name').get(0)
        def adLinkList = params.list('ad_link').get(0)
        def displayTextList = params.list('display_text').get(0)
        def priceList = params.list('price').get(0)
        Integer campId = params.int('id')
        Campaign campaign = Campaign.get(campId)
        if (!campaign) {
            String message = "找不到相對應廣告"
            println message
            redirect(controller: "advertiser", action: "index", params: [message: message])
            return
        }

        adTypeList.each { adType ->
            def creative
            def i = adType.key
            if (adType.value == 'video') {
                creative = new VideoAdCreative(name: adNameList[i],
                        link: adLinkList[i],
                        displayText: displayTextList[i],
                        imageUrl: "tmp",
                        price: priceList[i],
                        campaign: campaign)
            }
            else if (adType.value == 'mobile') {
                creative = new MobileAdCreative(name: adNameList[i],
                        link: adLinkList[i],
                        displayText: displayTextList[i],
                        imageUrl: "tmp",
                        price: priceList[i], campaign: campaign)
            }

            def returnVal = validateCreative(creative)
            if (returnVal != [:])
            {
                trunBackCreativeList.add(returnVal)
            }
            else {
                campaign.addToCreatives(creative)
                if(campaign.save() && creative.save())
                {
                    creative.imageUrl = uploadFile(creative.id, i)
                    creative.save()
                }
            }
        }

        if (trunBackCreativeList.size() > 0)
        {
            Map modelMap = [:]
            modelMap.creativeList = trunBackCreativeList
            modelMap.campaignCount = Campaign.count()
            modelMap.campaignId = params.int('id')
            goBackToAdd(modelMap)
        }
        else
        {
            redirect(controller: "advertiser", action: "index")
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
            String result = tmp == 'tmp'?uploadFile(params.id, 0):tmp
            creative.setProperties(name: params.ad_name,
                    link: params.ad_link,
                    displayText: params.display_text,
                    imageUrl: result,
                    price: params.price)
            def returnVal = validateCreative(creative)
            if (returnVal != [:]) {
                goBackToEdit(returnVal)
            }
            else if (creative.save())
            {
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

    /*
         *  (not an action method)
         *  檢查圖片是否符合格式
         */
    protected String validateImg()
    {
        MultipartFile file = request.getFile('upload_file')
        if (!file) {
            return "no Image"
        }

        if (!file.isEmpty()) {
            BufferedImage image = ImageIO.read(file.getInputStream());
            def allowContentTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif']

            if (!allowContentTypes.contains(file.getContentType())) {
                println("Image type must be one of: ${allowContentTypes}")
                return "reject"
            } else if (image.getWidth() > 360 && image.getHeight() > 50) {
                println("Image too big")
                return "reject"
            } else {
                return "tmp"
            }
        }

        return "no Image"
    }

    /*
         *  (not an action method)
         *  檢查輸入的creative 資料是否正確
         *  若不正確，則導回前一個畫面，並顯示錯誤訊息
         */
    protected Map validateCreative(creative)
    {
        Map modelMap = [:]

        if (!creative.validate())
        {
            creative.errors.each {println it}

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


            modelMap.creative = creative
            modelMap.errorMesseage = errorMesseage
        }

        return modelMap
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
    protected String uploadFile(fileName, index)
    {
        MultipartFile file = request.getFile("upload_file.${index}")
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

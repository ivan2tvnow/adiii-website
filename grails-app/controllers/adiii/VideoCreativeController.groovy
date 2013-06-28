package adiii

import grails.plugins.springsecurity.Secured
import org.springframework.web.multipart.MultipartFile

class VideoCreativeController
{
    def fileUploadService

    def edit()
    {
        Map modelMap = [:]
        Integer crativeId = params.int('id')
        VideoCreative creative = VideoCreative.get(crativeId)

        if (creative) {
            modelMap.creative = creative
            render(view: "../advertiser/editvidadcreative", model: modelMap)
        }
        else
        {
            render "<h1>No such resource!</h1>"
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

        MultipartFile file = request.getFile('upload_file')
        String extension = file.contentType.split("/")[1]
        String result = fileUploadService.uploadFile(file, "${campId}.${extension}")

        VideoCreative creative = new VideoCreative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: result,
                price: params.price)
        campaign.addToCreatives(creative)

        if(campaign.save())
        {
            String message = "廣告新增成功"
            redirect(controller: "advertiser", action: "index", params: [message: message])
        }
        else
        {
            String message = ""
            campaign.errors.each {
                message += (it.toString() +'\n')
            }
            message = "資料出錯"
            new File(result).delete()

            redirect(controller: "advertiser", action: "addvidadcreative", id: campId, params: [message: message])
        }
    }

    def update() {
        Integer crativeId = params.int('id')
        VideoCreative creative = VideoCreative.get(crativeId)

        MultipartFile file = request.getFile('upload_file')
        String extension = file.contentType.split("/")[1]
        String result = fileUploadService.uploadFile(file, "${creative.campaign.id}.${extension}")


        creative .setProperties(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: result,
                price: params.price)

        if(creative.save())
        {
            String message = "修改成功"

            redirect(controller: "advertiser", action: "index", params: [message: message])
        }
        else
        {
            String message = ""
            creative.errors.each {
                message += (it.toString() +'\n')
            }
            message = "資料出錯"

            redirect(action: "edit", id: params.id, params: [message: message])
        }
    }
}

package adiii

import grails.plugins.springsecurity.Secured
import org.springframework.web.multipart.MultipartFile

class CreativeController
{
    def fileUploadService

    /*
     *  URL: /advertiser/creative/save/${campaign.id}
     *  實際進行廣告內容(creative)儲存的action method; 當儲存成功後, 將網頁導至/advertiser/index.
     */
    @Secured(['ROLE_ADVERTISER'])
    def save()
    {
        Integer campId = params.int('id')
        Campaign campaign = Campaign.get(campId)
        println campaign

        MultipartFile file = request.getFile('upload_file')
        String extension = file.contentType.split("/")[1]
        String result = fileUploadService.uploadFile(file, "${campId}.${extension}")

        Creative creative = new Creative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: result)
        campaign.addToCreatives(creative)

        if(campaign.save())
        {
            campaign.errors.each {
                println it
            }
            redirect(controller: "advertiser", action: "index")
        }
        else
        {
            campaign.errors.each {
                println it
            }
        }
    }
}

package adiii

import org.springframework.web.multipart.MultipartFile

class MobileAdCreativeController extends CreativeController
{
    protected String editPage = "editmobileadcreative"

    protected def withCreative(id="id", Closure c)
    {
        MobileAdCreative creative = MobileAdCreative.get(params[id])
        if (creative)
        {
            c.call creative
        }
        else
        {
            render "<h1>No such resource!</h1>"
        }
    }

    protected def withParamSetup(id="id", Closure c) {
        Integer campId = params.int(id)
        MultipartFile file = request.getFile('upload_file')
        String extension = file.contentType.split("/")[1]
        String result = fileUploadService.uploadFile(file, "${campId}.${extension}")

        MobileAdCreative creative = new MobileAdCreative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: result,
                price: params.price)

        c.call creative
    }

    protected def goBackToEdit(campId, message)
    {
        redirect(controller: "advertiser", action: "addmobileadcreative", id: campId, params: [message: message])
    }
}

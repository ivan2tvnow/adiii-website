package adiii

import org.springframework.web.multipart.MultipartFile

class VideoAdCreativeController extends CreativeController
{
    protected String addPage = "addvidadcreative"
    protected String editPage = "editvidadcreative"

    protected def withCreative(id="id", Closure c)
    {
        VideoAdCreative creative = VideoAdCreative.get(params[id])
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

        VideoAdCreative creative = new VideoAdCreative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: result,
                price: params.price)

        c.call creative
    }
}

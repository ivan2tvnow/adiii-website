package adiii

import org.springframework.web.multipart.MultipartFile

class VideoAdCreativeController extends CreativeController
{
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
        VideoAdCreative creative = new VideoAdCreative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: "tmp",
                price: params.price)

        c.call creative
    }

    protected def goBackToEdit(campId, message)
    {
        redirect(controller: "advertiser", action: "addvidadcreative", id: campId, params: [message: message])
    }
}

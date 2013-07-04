package adiii

class VideoAdCreativeController extends CreativeController
{

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

    protected def goBackToAdd(modelMap)
    {
        render(view: "../advertiser/addvidadcreative", model: modelMap)
    }

    protected def goBackToEdit(modelMap)
    {
        render(view: "../advertiser/editvidadcreative", model: modelMap)
    }
}

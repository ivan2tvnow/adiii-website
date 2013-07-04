package adiii

import org.springframework.web.multipart.MultipartFile

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

class MobileAdCreativeController extends CreativeController
{
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

    protected def withParamSetup(id="id", Closure c)
    {
        MobileAdCreative creative = new MobileAdCreative(name: params.ad_name,
                link: params.ad_link,
                displayText: params.display_text,
                imageUrl: validateImg(),
                price: params.price)

        c.call creative
    }

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

    protected def goBackToAdd(modelMap)
    {
        render(view: "../advertiser/addmobileadcreative", model: modelMap)
    }

    protected def goBackToEdit(modelMap)
    {
        render(view: "../advertiser/editmobileadcreative", model: modelMap)
    }
}

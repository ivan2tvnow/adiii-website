package adiii

import javax.imageio.ImageIO
import java.awt.image.BufferedImage

class ImgTools {

    static Map getImgSize(imgPath) {
        def retImg = [:]
        File file = new File(imgPath)
        if (file) {
            try {
                def image = ImageIO.read(file);

                retImg.width = image.getWidth()
                retImg.hight = image.getHeight()
            } catch (Exception e) {
                retImg.width = 0
                retImg.hight = 0
            }

        }

        return retImg
    }
}

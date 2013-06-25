package adiii

import org.codehaus.groovy.grails.web.context.ServletContextHolder
import org.springframework.web.multipart.MultipartFile

class FileUploadService {

    boolean transactional = true

    def uploadFile(MultipartFile file, String name)
    {
        String storagePath = ""
        def servletContext = ServletContextHolder.servletContext
        storagePath = servletContext.getRealPath('assets')

        def storageDir = new File(storagePath)
        if(!storageDir.exists())
        {
            print "Creating directory ${storagePath}: "
            if(storageDir.mkdirs())
            {
                println "SUCCESS"
            }
            else
            {
                println "FAILED"
            }
        }

        if (!file.isEmpty())
        {
            file.transferTo(new File("${storagePath}/${name}"))
            println "Saved file: ${storagePath}/${name}"
            return "${storagePath}/${name}"

        } else {
            println "File ${file.inspect()} was empty!"
            return null
        }
    }
}

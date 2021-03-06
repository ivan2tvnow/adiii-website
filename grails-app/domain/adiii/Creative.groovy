package adiii

class Creative
{
    String name
    String link
    String displayText
    String imageUrl
    BigDecimal price

    static belongsTo = [campaign: Campaign]
    static hasMany = [clicks: Click, creativeViews: CreativeView]

    static constraints = {
        name(blank: false, size: 1..150, unique: true)
        link blank: false, url: true, validator: {val, obj ->
            try {
                def url = new URL(val)
                def connection = url.openConnection()
                connection.setRequestMethod("GET")
                connection.connect()
                if (connection.responseCode == 200 || connection.responseCode == 201) {
                   return true
                }
                return false
            } catch (Exception e) {
                return false
            }
        }
        displayText(blank:false, size: 1..48)
        imageUrl(blank:false)
    }

    static mapping = {
        sort "id"
    }

    def afterDelete()
    {
        try {
            def fileToDelete = new File(imageUrl)
            fileToDelete.delete()
        } catch (Exception e) {
            println e
        }
    }

}

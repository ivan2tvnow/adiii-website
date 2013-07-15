package adiii

class Click
{
    String deviceId
    String ipAddress
    Date createdDatetime = new Date()

    static belongsTo = [creative: Creative]

    static constraints = {
        ipAddress(blank: false)
    }
}

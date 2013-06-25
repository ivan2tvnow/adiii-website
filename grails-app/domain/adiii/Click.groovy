package adiii

class Click
{
    String deviceId
    String ipAddress
    Date createdDatetime = new Date()

    static belongsTo = Creative

    static constraints = {
        ipAddress(blank: false)
    }
}
